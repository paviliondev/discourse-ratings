/* eslint-disable ember/no-observers */
import { get, observer } from "@ember/object";
import { alias, and, notEmpty, or } from "@ember/object/computed";
import { getOwner } from "@ember/owner";
import { run } from "@ember/runloop";
import discourseDebounce from "discourse/lib/debounce";
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

    withPluginApi((api) => {
      const currentUser = api.getCurrentUser();

      api.addTrackedPostProperties("ratings");

      // Which rating types apply (reactive to category/tags/post) is kept
      // separate from the user's entered values (`ratingValues`, plain state).
      api.addModelGetter("composer", "editingPostWithRatings", function () {
        return this.editingPost && this.post?.ratings?.length;
      });

      api.addModelGetter("composer", "hasRatingTypes", function () {
        return this.ratingTypes.length > 0;
      });

      api.addModelGetter("composer", "showRatings", function () {
        return this.hasRatingTypes || this.editingPostWithRatings;
      });

      api.addModelGetter("composer", "allowedRatingTypes", function () {
        const site = this.site;
        let types = [];

        if (this.category) {
          const categoryTypes =
            site.category_rating_types[Category.slugFor(this.category)];
          if (categoryTypes) {
            types.push(...categoryTypes);
          }
        }

        // `tags` is a plain (non-tracked) composer property, so read it through
        // `get` to establish autotracking for this getter and its observers.
        const tags = get(this, "tags");
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
      });

      api.addModelGetter("composer", "ratingTypes", function () {
        let userCanRate;
        if (this.topic) {
          userCanRate = this.topic.user_can_rate;
        }
        let types = [];

        if (this.editingPostWithRatings) {
          types.push(...this.post.ratings.map((r) => r.type));
        }

        if (this.topicFirstPost && this.allowedRatingTypes.length) {
          this.allowedRatingTypes.forEach((t) => {
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
      });

      // User-entered rating values, keyed by type.
      api.addModelField("composer", "ratingValues", {
        defaultValue: () => ({}),
      });

      api.addModelGetter("composer", "ratings", function () {
        const typeNames = this.site.rating_type_names;
        const values = this.ratingValues;
        const postRatings =
          (this.editingPostWithRatings && this.post?.ratings) || [];

        return this.ratingTypes.map((type) => {
          const override = values[type];

          let value;
          let include;

          if (override) {
            value = override.value;
            include = override.include;
          } else {
            const currentRating = postRatings.find((r) => r.type === type);
            if (currentRating) {
              value = currentRating.value;
              include = currentRating.weight > 0;
            }
          }

          const rating = { type, value, include: include ?? false };

          if (typeNames && typeNames[type]) {
            rating.typeName = typeNames[type];
          }

          return rating;
        });
      });

      api.addModelMethod(
        "composer",
        "setRating",
        function (type, value, include) {
          this.ratingValues = {
            ...this.ratingValues,
            [type]: { value, include },
          };
        }
      );

      api.addModelGetter("composer", "ratingsToSave", function () {
        return this.ratings.map((r) => ({
          type: r.type,
          value: r.value,
          weight: r.include ? 1 : 0,
        }));
      });

      api.addModelAccessor("composer", "ratingsString", {
        get() {
          return JSON.stringify(this.ratingsToSave);
        },

        set(value) {
          if (value) {
            const values = { ...this.ratingValues };
            JSON.parse(value).forEach((r) => {
              values[r.type] = { value: r.value, include: true };
            });
            this.ratingValues = values;
          }
        },
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

        _shouldSaveDraft: observer(
          "model.reply",
          "model.title",
          "model.ratingValues",
          function () {
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
          }
        ),
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

        init() {
          this._super(...arguments);
          const topicController = getOwner(this).lookup("controller:topic");
          this.set("topicController", topicController);
        },
      });

      api.modifyClass("component:composer-body", {
        pluginId: PLUGIN_ID,

        resizeIfShowRatings: observer("composer.showRatings", function () {
          if (this.get("composer.viewOpen")) {
            this._triggerComposerResized();
          }
        }),

        didRender() {
          this._super(...arguments);
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
