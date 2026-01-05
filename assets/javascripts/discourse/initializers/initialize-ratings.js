import { getOwner } from "@ember/application";
import { computed } from "@ember/object";
import { alias, and, notEmpty, or } from "@ember/object/computed";
import { run } from "@ember/runloop";
import discourseDebounce from "discourse/lib/debounce";
import {
  default as discourseComputed,
  observes,
  on,
} from "discourse/lib/decorators";
import { isTesting } from "discourse/lib/environment";
import { withPluginApi } from "discourse/lib/plugin-api";
import Category from "discourse/models/category";
import Composer from "discourse/models/composer";
import { i18n } from "discourse-i18n";

const PLUGIN_ID = "discourse-ratings";

export default {
  name: "initialize-ratings",
  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");

    if (!siteSettings.rating_enabled) {
      return;
    }

    Composer.serializeOnCreate("ratings", "ratingsString");
    Composer.serializeOnUpdate("ratings", "ratingsString");
    Composer.serializeToDraft("ratings", "ratingsString");

    withPluginApi("0.10.0", (api) => {
      const currentUser = api.getCurrentUser();

      api.addTrackedPostProperties("ratings");

      api.modifyClass("model:composer", {
        pluginId: PLUGIN_ID,
        editingPostWithRatings: and("editingPost", "post.ratings.length"),
        hasRatingTypes: notEmpty("ratingTypes"),
        showRatings: or("hasRatingTypes", "editingPostWithRatings"),

        @discourseComputed(
          "editingPostWithRatings",
          "topicFirstPost",
          "post.ratings",
          "allowedRatingTypes.[]"
        )
        ratingTypes(
          editingPostWithRatings,
          topicFirstPost,
          postRatings,
          allowedRatingTypes
        ) {
          let userCanRate;
          if (this.topic) {
            userCanRate = this.topic.user_can_rate;
          }
          let types = [];

          if (editingPostWithRatings) {
            types.push(...postRatings.map((r) => r.type));
          }

          if (topicFirstPost && allowedRatingTypes.length) {
            allowedRatingTypes.forEach((t) => {
              if (types.indexOf(t) === -1) {
                types.push(t);
              }
            });
          } else if (userCanRate && userCanRate.length) {
            userCanRate.forEach((t) => {
              if (types.indexOf(t) === -1) {
                types.push(t);
              }
            });
          }

          return types;
        },

        ratings: computed(
          "ratingTypes",
          "editingPostWithRatings",
          "post.ratings",
          {
            get() {
              const typeNames = this.site.rating_type_names;

              let result = this.ratingTypes.map((type) => {
                let currentRating = (
                  (this.post && this.post.ratings) ||
                  []
                ).find((r) => r.type === type);

                let value;
                let include;

                if (this.editingPostWithRatings && currentRating) {
                  value = currentRating.value;
                  include = currentRating.weight > 0 ? true : false;
                }

                let rating = {
                  type,
                  value,
                  include: include !== null ? include : true,
                };

                if (typeNames && typeNames[type]) {
                  rating.typeName = typeNames[type];
                }

                return rating;
              });
              return result;
            },

            set(key, value) {
              const typeNames = this.site.rating_type_names;

              let result = this.ratingTypes.map((type) => {
                let currentRating = (value || []).find((r) => r.type === type);

                let score;
                let include;

                if (this.hasRatingTypes && currentRating) {
                  score = currentRating.value;
                  include = currentRating.value > 0 ? true : false;
                }

                let rating = {
                  type,
                  value: score,
                  include: include !== null ? include : true,
                };

                if (typeNames && typeNames[type]) {
                  rating.typeName = typeNames[type];
                }

                return rating;
              });
              return result;
            },
          }
        ),

        @discourseComputed("tags", "category")
        allowedRatingTypes(tags, category) {
          const site = this.site;
          let types = [];

          if (category) {
            const categoryTypes =
              site.category_rating_types[Category.slugFor(category)];
            if (categoryTypes) {
              types.push(...categoryTypes);
            }
          }

          if (tags) {
            const tagTypes = site.tag_rating_types;
            if (tagTypes) {
              tags.forEach((t) => {
                if (tagTypes[t]) {
                  types.push(...tagTypes[t]);
                }
              });
            }
          }

          return types;
        },

        @discourseComputed("ratings.@each.{value}")
        ratingsToSave(ratings) {
          return ratings.map((r) => ({
            type: r.type,
            value: r.value,
            weight: r.include ? 1 : 0,
          }));
        },

        ratingsString: computed("ratingsToSave.@each.value", {
          get() {
            return JSON.stringify(this.ratingsToSave);
          },

          set(key, value) {
            if (value) {
              const typeNames = this.site.rating_type_names;

              const draftRatings = JSON.parse(value).map((r) => {
                return {
                  type: r.type,
                  value: r.value,
                  typeName: typeNames[r.type],
                  include: true,
                };
              });
              this.set("ratings", draftRatings);
            }
            let result = value || JSON.stringify(this.ratingsToSave);
            return result;
          },
        }),
      });

      api.modifyClass("service:composer", {
        pluginId: PLUGIN_ID,

        save(ignore, event) {
          const model = this.model;
          const ratings = model.ratings;
          const showRatings = model.showRatings;

          if (showRatings && ratings.some((r) => r.include && !r.value)) {
            const dialog = api.container.lookup("service:dialog");
            return dialog.alert(i18n("composer.select_rating"));
          }

          return this._super(ignore, event);
        },

        @observes("model.reply", "model.title", "model.ratings.@each.{value}")
        _shouldSaveDraft() {
          if (
            this.model &&
            !this.model.loading &&
            !this.skipAutoSave &&
            !this.model.disableDrafts
          ) {
            if (!this._lastDraftSaved) {
              // pretend so we get a save unconditionally in 15 secs
              this._lastDraftSaved = Date.now();
            }
            if (Date.now() - this._lastDraftSaved > 15000) {
              this._saveDraft();
            } else {
              let method = isTesting() ? run : discourseDebounce;
              this._saveDraftDebounce = method(this, this._saveDraft, 2000);
            }
          }
        },
      });

      api.registerCustomPostMessageCallback("ratings", (controller, data) => {
        const model = controller.get("model");
        const typeNames = controller.site.rating_type_names;

        data.ratings.forEach((r) => {
          if (typeNames && typeNames[r.type]) {
            r.type_name = typeNames[r.type];
          }
        });

        model.set("ratings", data.ratings);
        model
          .get("postStream")
          .triggerChangedPost(data.id, data.updated_at)
          .then(() => {
            controller.appEvents.trigger("post-stream:refresh", {
              id: data.id,
            });
          });

        if (data.user_id === currentUser.id) {
          model.set("user_can_rate", data.user_can_rate);
        }

        controller.appEvents.trigger("header:update-topic", model);
      });

      api.registerValueTransformer(
        "topic-list-item-class",
        ({ value: classNames, context }) => {
          const topic = context.topic;
          if (topic.show_ratings && topic.ratings) {
            classNames.push("has-ratings");
          }
          return classNames;
        }
      );

      api.modifyClass("component:topic-title", {
        pluginId: PLUGIN_ID,
        hasRatings: alias("model.show_ratings"),
        editing: alias("topicController.editingTopic"),
        hasTags: notEmpty("model.tags"),
        showTags: and("hasTags", "siteSettings.tagging_enabled"),
        hasFeaturedLink: notEmpty("model.featured_link"),
        showFeaturedLink: and(
          "hasFeaturedLink",
          "siteSettings.topic_featured_link_enabled"
        ),
        hasExtra: or("showTags", "showFeaturedLink"),
        classNameBindings: ["hasRatings", "editing", "hasExtra"],

        @on("init")
        setupController() {
          const topicController = getOwner(this).lookup("controller:topic");
          this.set("topicController", topicController);
        },
      });

      api.modifyClass("component:composer-body", {
        pluginId: PLUGIN_ID,

        @observes("composer.showRatings")
        resizeIfShowRatings() {
          if (this.get("composer.viewOpen")) {
            this._triggerComposerResized();
          }
        },

        @on("didRender")
        addContainerClass() {
          if (!this.element || this.isDestroying || this.isDestroyed) {
            return;
          }

          if (this.composer && this.composer.showRatings) {
            if (!this.element.classList.contains("reply-control-ratings")) {
              this.element.classList.add("reply-control-ratings");
            }
          }
        },
      });
    });
  },
};
