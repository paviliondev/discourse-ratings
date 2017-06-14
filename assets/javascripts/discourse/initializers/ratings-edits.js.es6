import Topic from 'discourse/models/topic';
import TopicController from 'discourse/controllers/topic';
import TopicRoute from 'discourse/routes/topic';
import ComposerController from 'discourse/controllers/composer';
import ComposerBody from 'discourse/components/composer-body';
import Composer from 'discourse/models/composer';
import Post from 'discourse/models/post';
import { registerUnbound } from 'discourse-common/lib/helpers';
import renderUnboundRating from 'discourse/plugins/discourse-ratings/lib/render-rating';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { ajax } from 'discourse/lib/ajax';
import { default as computed, on, observes } from 'ember-addons/ember-computed-decorators';

export default {
  name: 'ratings-edits',
  initialize(){

    withPluginApi('0.1', api => {
      api.includePostAttributes('rating')

      api.decorateWidget('poster-name:after', function(helper) {
        const rating = helper.attrs.rating;
        const model = helper.getModel();

        if (model && model.topic.rating_enabled && rating) {
          let html = new Handlebars.SafeString(renderUnboundRating(rating));
          return helper.rawHtml(`${html}`);
        }
      })
    });

    Composer.serializeOnCreate('rating')
    Composer.serializeToTopic('rating')

    Composer.reopen({
      includeRating: true,

      @on('init')
      @observes('post')
      setRating() {
        const post = this.get('post')
        if (this.get('editingPost') && post && post.rating) {
          this.set('rating', post.rating);
        }
      },

      @computed('currentType','tags','categoryId')
      ratingEnabled(type, tags, categoryId) {
        let category = Discourse.Category.findById(categoryId),
            catEnabled = category && category.rating_enabled,
            tagEnabled = tags && tags.filter(function(t){
                            return Discourse.SiteSettings.rating_tags.split('|').indexOf(t) != -1;
                         }).length > 0,
            typeEnabled = type === 'rating';

        return catEnabled || tagEnabled || typeEnabled;
      },

      @computed('ratingEnabled', 'hideRating', 'topic', 'post')
      showRating(ratingEnabled, hideRating, topic, post) {
        if (hideRating) return false;

        // creating or editing first post
        if ((post && post.get('firstPost') && topic.rating_enabled) || !topic) {
          return ratingEnabled;
        }

        // creating post other than first post
        if (topic.can_rate) return true;

        // editing post other than first post
        return topic.rating_enabled && post && post.rating && (this.get('action') === Composer.EDIT);
      }
    })

    ComposerController.reopen({
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
         Post.removeRating(post.id);
         this.get('topicController').toggleCanRate();
        } else {
         Post.editRating(post.id, rating);
        }
      }
    })

    ComposerBody.reopen({
      @observes('composer.showRating')
      resizeIfShowRating: function() {
        if (this.get('composer.composeState') === Composer.OPEN) {
          this.resize();
        }
      }
    })

    registerUnbound('rating-unbound', function(rating) {
      return new Handlebars.SafeString(renderUnboundRating(rating));
    });

    Post.reopenClass({
      removeRating(postId) {
         return ajax("/rating/remove", {
           type: 'POST',
           data: {
             id: postId,
           }
         }).then(function (result, error) {
           if (error) {
             popupAjaxError(error);
           }
         });
       },

       editRating(postId, rating) {
         return ajax("/rating/rate", {
           type: 'POST',
           data: {
             id: postId,
             rating: rating
           }
         }).then(function (result, error) {
           if (error) {
             popupAjaxError(error);
           }
         });
       }
    })

    TopicController.reopen({
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
                  refresh({ id: data.post_id });
                );
              }
            }
          })

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
    })
  }
}
