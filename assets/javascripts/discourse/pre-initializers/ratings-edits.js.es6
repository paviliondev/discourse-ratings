import Topic from 'discourse/models/topic';
import TopicController from 'discourse/controllers/topic';
import TopicRoute from 'discourse/routes/topic';
import ComposerController from 'discourse/controllers/composer';
import ComposerView from 'discourse/views/composer';
import Composer from 'discourse/models/composer';
import Post from 'discourse/models/post';
import { registerUnbound } from 'discourse-common/lib/helpers';
import renderUnboundRating from 'discourse/plugins/discourse-ratings/lib/render-rating';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { withPluginApi } from 'discourse/lib/plugin-api';
import { ajax } from 'discourse/lib/ajax';

export default {
  name: 'ratings-edits',
  initialize(){

    withPluginApi('0.1', api => {
      api.includePostAttributes('rating')
      api.decorateWidget('poster-name:after', function(helper) {
        let rating = helper.attrs.rating,
            showRating = helper.getModel().topic.rating_enabled;
        if (showRating && rating) {
          var html = new Handlebars.SafeString(renderUnboundRating(rating))
          return helper.rawHtml(`${html}`)
        }
      })
    });

    Composer.serializeOnCreate('rating')

    Composer.serializeToTopic('rating')

    Composer.reopen({
      setRating: function() {
        const post = this.get('post')
        if (this.get('editingPost') && post && post.rating) {
          this.set('rating', post.rating)
        }
      }.observes('post').on('init')
    })

    ComposerController.reopen({
      includeRating: true,

      actions: {
        save() {
          if (this.get('showRating') && this.get('includeRating') && !this.get('model.rating')) {
            return bootbox.alert(I18n.t("composer.select_rating"))
          }
          this.save()
        }
      },

      showRating: function() {
        let model = this.get('model')
        if (!model) {return false}

        let topic = model.get('topic'),
            post = model.get('post'),
            firstPost = post && post.get('firstPost');

        // creating or editing first post
        if ((firstPost && topic.rating_enabled) || !topic) {
          return this.get('ratingEnabled')
        }

        // creating post other than first post
        if (topic.can_rate) { return true }

        // editing post other than first post
        return topic.rating_enabled && post && post.rating && (model.get('action') === Composer.EDIT)
      }.property('ratingEnabled', 'model.topic', 'model.post'),

      ratingEnabled: function() {
        let category = Discourse.Category.findById(this.get('model.categoryId')),
            tags = this.get('model.tags'),
            catEnabled = category && category.rating_enabled,
            tagEnabled = tags && tags.filter(function(t){
                            return Discourse.SiteSettings.rating_tags.split('|').indexOf(t) != -1;
                         }).length > 0
        return catEnabled || tagEnabled
      }.property('model.tags', 'model.categoryId'),

      saveRatingAfterEditing: function() {
       // only continue if user was editing and composer is now closed
       if (!this.get('showRating')
           || this.get('model.action') !== Composer.EDIT
           || this.get('model.composeState') !== Composer.SAVING) {return}

       let post = this.get('model.post'),
           rating = this.get('model.rating');

       if (rating && !this.get('includeRating')) {
         this.removeRating(post)
         this.get('topicController').toggleCanRate()
       } else {
         this.editRating(post, rating)
       }
     }.observes('model.composeState'),

     removeRating: function(post) {
       let self = this
        ajax("/rating/remove", {
          type: 'POST',
          data: {
            id: post.id,
          }
        }).then(function (result, error) {
          if (error) {
            popupAjaxError(error);
          }
        });
      },

      editRating: function(post, rating) {
        let self = this
        post.set('rating', rating)
        ajax("/rating/rate", {
          type: 'POST',
          data: {
            id: post.id,
            rating: rating
          }
        }).then(function (result, error) {
          if (error) {
            popupAjaxError(error);
          }
        });
      }

    })

    ComposerView.reopen({
      resizeIfShowRating: function() {
        if (this.get('composeState') === Composer.OPEN) {
          this.resize()
        }
      }.observes('controller.showRating')
    })

    registerUnbound('rating-unbound', function(rating) {
      return new Handlebars.SafeString(renderUnboundRating(rating));
    });

    TopicController.reopen({
      refreshAfterTopicEdit: false,

      subscribeToRatingUpdates: function() {
        let model = this.get('model'),
            postStream = model.get('postStream'),
            refresh = (args) => this.appEvents.trigger('post-stream:refresh', args);

        if (model.rating_enabled && postStream.get('loaded')) {
          this.messageBus.subscribe("/topic/" + model.id, function(data) {
            if (data.type === 'revised') {
              if (data.average !== undefined) {
                model.set('average_rating', data.average)
              }
              if (data.post_id !== undefined) {
                postStream.triggerChangedPost(data.post_id, data.updated_at).then(() =>
                  refresh({ id: data.post_id })
                );
              }
            }
          })
        }
      }.observes('model.postStream.loaded'),

      showRating: function() {
        if (this.get('model.average_rating') < 1) {return false}
        if (!this.get('editingTopic')) {return this.get('model.rating_enabled')}

        let category = Discourse.Category.findById(this.get('buffered.category_id')),
            tags = this.get('buffered.tags'),
            catEnabled = category && category.rating_enabled,
            ratingTags = tags && tags.filter(function(t){
                            return Discourse.SiteSettings.rating_tags.split('|').indexOf(t) != -1;
                         }),
            ratingsVisible = Boolean(ratingTags.length || catEnabled)

        if (ratingsVisible !== this.get('model.rating_enabled')) {
          this.set('refreshAfterTopicEdit', true)
        }
        return ratingsVisible
      }.property('model.average_rating', 'model.rating_enabled', 'buffered.category_id', 'buffered.tags'),

      refreshPostRatingVisibility: function() {
        if (!this.get('editingTopic') && this.get('refreshAfterTopicEdit')) {
         this.get('model.postStream').refresh()
         this.set('refreshAfterTopicEdit', false)
        }
      }.observes('editingTopic'),

      toggleCanRate: function() {
        if (this.get('model')) {
          this.toggleProperty('model.can_rate')
        }
      }
    })
  }
}
