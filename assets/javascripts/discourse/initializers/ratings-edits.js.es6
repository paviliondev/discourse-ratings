import Composer from 'discourse/models/composer';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { default as computed, on, observes } from 'ember-addons/ember-computed-decorators';
import {
  ratingEnabled,
  removeRating,
  editRating,
  ratingListHtml,
  typeName
} from '../lib/rating-utilities';

export default {
  name: 'ratings-edits',
  initialize(){
    Composer.serializeOnCreate('ratings', 'ratingsString');

    withPluginApi('0.8.10', api => {
      api.includePostAttributes('ratings');

      api.decorateWidget('poster-name:after', function(helper) {
        const model = helper.getModel();
        
        if (model.topic.rating_enabled && model.ratings) {
          let html = ratingListHtml(model.ratings);
          return helper.rawHtml(`${new Handlebars.SafeString(html)}`);
        }
      });

      api.modifyClass('model:composer', {
        includeRating: false,
        includeRatingTargetId: false,
        ratingTargetId: undefined,

        @on('init')
        @observes('post', 'showRating')
        setRating() {
          const post = this.post;
          const category = this.category;
          
          if (this.showRating) {
            let ratings;
            
            if (this.creatingTopic && this.category) {
              ratings = category.rating_types.map(type => {
                return {
                  value: null,
                  type,
                  include: true
                }
              })
            }

            if (this.editingPost && post && post.ratings) {
              ratings = post.ratings.map(rating => {
                return {
                  value: rating.value,
                  type: rating.type,
                  include: true
                }
              });
            }
            
            if (ratings) {
              this.set('bufferedRatings', ratings);
            }
          }
        },

        @computed('tags','categoryId')
        ratingEnabled(tags, categoryId) {
          return ratingEnabled(tags, categoryId);
        },

        @computed('ratingEnabled', 'hideRating', 'topic', 'post')
        showRating(ratingEnabled, hide, topic, post) {
          if (hide) return false;

          if (!topic || ((post && post.firstPost) && (topic.rating_enabled))) {
            return ratingEnabled;
          }
          
          return topic.can_rate ||
            (topic.rating_enabled && post && post.ratings && (this.get('action') === Composer.EDIT));
        },
        
        @computed('ratings')
        ratingsString(ratings) {
          return JSON.stringify(ratings);
        }
      });

      api.modifyClass('controller:composer', {
        actions: {
          save() {
            const showRating = this.get('model.showRating');
            const includeRating = this.get('model.includeRating');
            const ratings = this.get('model.ratings');

            if (showRating && includeRating && !ratings) {
              return bootbox.alert(I18n.t("composer.select_rating"));
            }

            let result = this.save();

            if (result) {
              Promise.resolve(result).then(() => {
                if (showRating && includeRating && ratings) {
                  const controller = this.get('topicController');
                  controller.toggleCanRate();
                }
              });
            };
          }
        },

        @observes('model.composeState')
        saveRatingAfterEditing() {
          // only continue if user was editing and composer is now closed
          if (!this.get('model.showRating')
             || this.get('model.action') !== Composer.EDIT
             || this.get('model.composeState') !== Composer.SAVING) { return; }

          const rating = this.get('model.ratings');

          if (ratings) {
            const post = this.get('model.post');
            const includeRating = this.get('model.includeRating');

            if (includeRating) {
              editRating(post.id, ratings);
            } else {
              removeRating(post.id);
              const controller = this.get('topicController');
              controller.toggleCanRate();
            }
          }
        }
      });

      api.modifyClass('component:composer-body', {
        @observes('composer.showRating')
        resizeIfShowRating: function() {
          if (this.get('composer.composeState') === Composer.OPEN) {
            this.resize();
          }
        }
      });

      api.modifyClass('model:topic', {
        @computed('tags','category_id')
        ratingEnabled(tags, categoryId) {
          return ratingEnabled(tags, categoryId);
        },

        @computed('ratingEnabled')
        showRatingTip(enabled) {
          return enabled && this.siteSettings.rating_show_topic_tip;
        }
      });

      api.modifyClass('controller:topic', {
        refreshAfterTopicEdit: false,

        @observes('editingTopic')
        refreshPostRatingVisibility() {
          if (!this.get('editingTopic') && this.get('refreshAfterTopicEdit')) {
           this.get('model.postStream').refresh();
           this.set('refreshAfterTopicEdit', false);
          }
        },

        toggleCanRate() {
          if (this.get('model')) {
            this.toggleProperty('model.can_rate');
          }
        }
      });
      
      api.registerCustomPostMessageCallback("ratings", (controller, data) => {
        const model = controller.get("model");        
        model.set('ratings', data.topic_ratings);
        model.get('postStream')
          .triggerChangedPost(data.id, data.updated_at)
          .then(() => {
            controller.appEvents.trigger("post-stream:refresh", { id: data.id });
          });
        
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
