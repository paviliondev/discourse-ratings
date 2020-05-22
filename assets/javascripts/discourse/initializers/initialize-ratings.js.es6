import Composer from 'discourse/models/composer';
import Category from 'discourse/models/category';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { default as discourseComputed, on, observes } from "discourse-common/utils/decorators";
import { notEmpty, and } from "@ember/object/computed";
import { ratingListHtml } from '../lib/rating-utilities';
import { scheduleOnce, later } from "@ember/runloop";

export default {
  name: 'initialize-ratings',
  initialize(container){
    Composer.serializeOnCreate('ratings', 'ratingsString');
    Composer.serializeOnUpdate('ratings', 'ratingsString');

    withPluginApi('0.10.0', api => {
      const currentUser = api.getCurrentUser();
      
      api.includePostAttributes("ratings");

      api.decorateWidget("poster-name:after", function(helper) {
        const post = helper.getModel();
                
        if (post.topic.show_ratings && post.ratings) {
          return helper.rawHtml(
            `${new Handlebars.SafeString(ratingListHtml(post.ratings))}`
          );
        }
      });
      
      api.reopenWidget("poster-name", {
        buildClasses(attrs) {
          const post = this.findAncestorModel();
          let classes = [];
          if (post &&
              post.topic &&
              post.topic.show_ratings &&
              post.ratings) {
            classes.push('has-ratings');
          }
          return classes;
        }
      })

      api.modifyClass('model:composer', {
        editingPostWithRatings: and('editingPost', 'post.ratings'),
        ratingEnabled: notEmpty('ratingTypes'),
        
        @discourseComputed('editingPostWithRatings', 'post.ratings', 'topicFirstPost', 'allowedRatingTypes.[]', 'topic.user_can_rate.[]')
        ratingTypes(editingPostWithRatings, postRatings, topicFirstPost, allowedRatingTypes, userCanRate) {
          let types = [];
          
          if (editingPostWithRatings) {
            types.push(...postRatings.map(r => r.type));
          }
          
          if (topicFirstPost) {
            allowedRatingTypes.forEach(t => {
              if (types.indexOf(t) === -1) {
                types.push(t);
              }
            });
          } else {
            userCanRate.forEach(t => {
              if (types.indexOf(t) === -1) {
                types.push(t);
              }
            })
          }
          
          return types;
        },
        
        @discourseComputed('ratingTypes', 'editingPostWithRatings', 'post.ratings')
        ratings(ratingTypes, editingPostWithRatings, postRatings) {
          const typeNames = this.site.rating_type_names;
          
          return ratingTypes.map(type => {
            let value;
                        
            if (editingPostWithRatings) {
              let rating = postRatings.find(r => r.type === type);
              value = rating ? rating.value : null;
            }
            
            let rating = {
              type,
              value,
              include: true
            };
                        
            if (typeNames && typeNames[type]) {
              rating.typeName = typeNames[type];
            }
            
            return rating;
          })
        },
        
        @discourseComputed('tags', 'category')
        allowedRatingTypes(tags, category) {
          const site = this.site;
          let types = [];
          
          if (category) {
            const categoryTypes = site.category_rating_types[Category.slugFor(category)];
            if (categoryTypes) {
              types.push(...categoryTypes);
            }
          }
          
          if (tags) {
            const tagTypes = site.tag_rating_types;
            if (tagTypes) {
              tags.forEach(t => {
                if (tagTypes[t]) {
                  types.push(...tagTypes[t]);
                }
              });
            }
          }
                    
          return types;
        },
        
        @discourseComputed('ratingEnabled', 'editingPostWithRatings')
        showRating(ratingEnabled, editingPostWithRatings) {
          return ratingEnabled || editingPostWithRatings;
        },
        
        @discourseComputed('ratings')
        ratingsToSave(ratings) {
          return ratings.filter(r => r.include && r.value)
            .map(r => ({ type: r.type, value: r.value }));
        },
        
        @discourseComputed('ratingsToSave')
        ratingsString(ratingsToSave) {
          return JSON.stringify(ratingsToSave);
        }
      });

      api.modifyClass('controller:composer', {
        save() {
          const model = this.model;
          const ratings = model.ratings;
          const showRating = model.showRating;
          
          if (showRating && ratings.some(r => r.include && !r.value)) {
            return bootbox.alert(I18n.t("composer.select_rating"));
          }
          
          return this._super();
        }
      });

      api.modifyClass('component:composer-body', {
        @observes('composer.showRating')
        resizeIfShowRating() {
          if (this.get('composer.viewOpen')) {
            this.resize();
          }
        }
      });
      
      api.registerCustomPostMessageCallback("ratings", (controller, data) => {
        const model = controller.get("model");
                
        model.set('ratings', data.ratings);
        model.get('postStream')
          .triggerChangedPost(data.id, data.updated_at)
          .then(() => {
            controller.appEvents.trigger("post-stream:refresh", { id: data.id });
          });
        
        if (data.user_id === currentUser.id) {
          model.set('user_can_rate', data.user_can_rate);
        }
        
        controller.appEvents.trigger("header:update-topic", model);
      });

      api.modifyClass('component:topic-list-item', {
        hasRatings: and('topic.show_ratings', 'topic.ratings'),
        
        @discourseComputed("topic", "lastVisitedTopic", "hasRatings")
        unboundClassNames(topic, lastVisitedTopic, hasRatings) {
          let classes = this._super(topic, lastVisitedTopic) || "";
          if (hasRatings) {
            classes += ' has-ratings';
          }
          return classes;
        }
      });
    });
  }
};
