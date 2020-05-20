import Composer from 'discourse/models/composer';
import Category from 'discourse/models/category';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { default as discourseComputed, on, observes } from "discourse-common/utils/decorators";
import { notEmpty, and } from "@ember/object/computed";
import { ratingListHtml, typeName } from '../lib/rating-utilities';

export default {
  name: 'initialize-ratings',
  initialize(container){
    Composer.serializeOnCreate('ratings', 'ratingsString');
    Composer.serializeOnUpdate('ratings', 'ratingsString');

    withPluginApi('0.10.0', api => {
      const currentUser = api.getCurrentUser();
      
      api.includePostAttributes('ratings');

      api.decorateWidget('poster-name:after', function(helper) {
        const post = helper.getModel();
                
        if (post.topic.show_ratings && post.ratings) {
          return helper.rawHtml(
            `${new Handlebars.SafeString(ratingListHtml(post.ratings))}`
          );
        }
      });

      api.modifyClass('model:composer', {
        editingPostWithRatings: and('editingPost', 'post.ratings'),
        ratingEnabled: notEmpty('ratingTypes'),
        
        @discourseComputed('editingPostWithRatings', 'post.ratings', 'topicFirstPost', 'allowedRatingTypes.[]', 'topic.user_can_rate.[]')
        ratingTypes(editingPostWithRatings, postRatings, topicFirstPost, allowedRatingTypes, userCanRate) {
          if (editingPostWithRatings) {
            return postRatings.map(r => r.type);
          } else if (topicFirstPost) {
            return allowedRatingTypes;
          } else {
            return userCanRate;
          }
        },
        
        @discourseComputed('ratingTypes', 'editingPostWithRatings', 'post.ratings')
        ratings(ratingTypes, editingPostWithRatings, postRatings) {
          return ratingTypes.map(type => {
            let value;
                        
            if (editingPostWithRatings) {
              let rating = postRatings.find(r => r.type === type);
              value = rating ? rating.value : null;
            }
            
            return {
              type,
              value,
              include: true
            }
          })
        },
        
        @discourseComputed('tags', 'category')
        allowedRatingTypes(tags, category) {
          const siteRatings = this.site.ratings;
          let types = [];
                              
          if (!siteRatings) {
            return types;
          }
          
          if (category) {
            const categoryTypes = siteRatings.categories[Category.slugFor(category)];
            if (categoryTypes) {
              types.push(...categoryTypes);
            }
          }
          
          if (tags) {
            tags.forEach(t => {
              if (siteRatings.tags[t]) {
                types.push(...siteRatings.tags[t]);
              }
            })
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
        @on('didReceiveAttrs')
        injectRatingTypeNames() {
          if (this.topic.ratings) {
            this.topic.ratings.forEach((rating) => {
              rating.name = typeName(rating.type)
            });
          }
        }
      });
    });
  }
};
