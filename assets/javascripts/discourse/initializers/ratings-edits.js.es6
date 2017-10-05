import Composer from 'discourse/models/composer';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { default as computed, on, observes } from 'ember-addons/ember-computed-decorators';
import { ratingEnabled, removeRating, editRating, unboundRating } from '../lib/rating-utilities';

export default {
  name: 'ratings-edits',
  initialize(){

    Composer.serializeOnCreate('rating');

    withPluginApi('0.8.10', api => {
      api.includePostAttributes('rating');

      api.decorateWidget('poster-name:after', function(helper) {
        const rating = helper.attrs.rating;
        const model = helper.getModel();

        if (model && model.topic && model.topic.rating_enabled && rating) {
          let html = new Handlebars.SafeString(unboundRating(rating));
          return helper.rawHtml(`${html}`);
        }
      });

      api.modifyClass('model:composer', {
        includeRating: true,

        @on('init')
        @observes('post')
        setRating() {
          const post = this.get('post');
          if (this.get('editingPost') && post && post.rating) {
            this.set('rating', post.rating);
          }
        },

        @computed('subtype','tags','categoryId')
        ratingEnabled(subtype, tags, categoryId) {
          return ratingEnabled(subtype, tags, categoryId);
        },

        @computed('ratingEnabled', 'hideRating', 'topic', 'post')
        showRating(enabled, hide, topic, post) {
          if (hide) return false;

          if ((post && post.get('firstPost') && topic.rating_enabled) || !topic) {
            return enabled;
          }

          if (topic.can_rate) return true;

          return topic.rating_enabled && post && post.rating && (this.get('action') === Composer.EDIT);
        }
      });

      api.modifyClass('controller:composer', {
        actions: {
          save() {
            if (this.get('model.showRating') && this.get('model.includeRating') && !this.get('model.rating')) {
              return bootbox.alert(I18n.t("composer.select_rating"));
            }
            this.save();
          }
        },

        @observes('model.composeState')
        saveRatingAfterEditing() {
          // only continue if user was editing and composer is now closed
          if (!this.get('model.showRating')
             || this.get('model.action') !== Composer.EDIT
             || this.get('model.composeState') !== Composer.SAVING) { return; }

          const post = this.get('model.post');
          const rating = this.get('model.rating');

          if (rating && !this.get('model.includeRating')) {
           removeRating(post.id);
           this.get('topicController').toggleCanRate();
          } else {
           editRating(post.id, rating);
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
        @computed('subtype','tags','category_id')
        ratingEnabled(type, tags, categoryId) {
          return ratingEnabled(type, tags, categoryId);
        },

        @computed('ratingEnabled')
        showRatingTip(enabled) {
          return enabled && this.siteSettings.rating_show_topic_tip;
        }
      });

      api.modifyClass('controller:topic', {
        refreshAfterTopicEdit: false,
        unsubscribed: false,

        unsubscribe() {
          const topicId = this.get('content.id');
          if (!topicId) return;

          this.messageBus.unsubscribe('/topic/*');
          this.set('unsubscribed', true);
        },

        @observes('unsubscribed', 'model.postStream')
        subscribeToRatingUpdates() {
          const unsubscribed = this.get('unsubscribed');
          const model = this.get('model');
          const subscribedTo = this.get('subscribedTo');

          if (!unsubscribed) return;
          this.set('unsubscribed', false);

          if (model && model.id === subscribedTo) return this.set('subscribedTo', null);
          this.set('subscribedTo', null);

          if (model && model.get('postStream') && model.rating_enabled) {
            const refresh = (args) => this.appEvents.trigger('post-stream:refresh', args);

            this.messageBus.subscribe("/topic/" + model.id, function(data) {
              if (data.type === 'revised') {
                if (data.average !== undefined) {
                  model.set('average_rating', data.average);
                }
                if (data.post_id !== undefined) {
                  model.get('postStream').triggerChangedPost(data.post_id, data.updated_at).then(() =>
                    refresh({ id: data.post_id })
                  );
                }
              }
            });

            this.set('subscribedTo', model.id);
          }
        },

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
    });
  }
};
