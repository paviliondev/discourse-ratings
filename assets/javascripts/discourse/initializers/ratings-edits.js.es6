import Topic from 'discourse/models/topic';
import TopicController from 'discourse/controllers/topic';
import TopicRoute from 'discourse/routes/topic';
import ComposerController from 'discourse/controllers/composer';
import ComposerView from 'discourse/views/composer';
import Composer from 'discourse/models/composer';
import registerUnbound from 'discourse/helpers/register-unbound';
import renderUnboundRating from 'discourse/plugins/discourse-ratings/lib/render-rating';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: 'ratings-edits',
  initialize(){

    withPluginApi('0.1', api => {
      api.includePostAttributes('rating')
      api.decorateWidget('poster-name:after', function(helper) {
        var rating = helper.attrs.rating,
            showRating = helper.getModel().topic.show_ratings;
        if (showRating && rating) {
          var html = new Handlebars.SafeString(renderUnboundRating(rating))
          return helper.rawHtml(`${html}`)
        }
      })
    });

    TopicController.reopen({
      refreshAfterTopicEdit: false,

      subscribeToRatingUpdates: function() {
        var model = this.get('model')
        if (model.show_ratings && this.get('model.postStream.loaded')) {
          this.messageBus.subscribe("/topic/" + model.id, function(data) {
            if (data.type === 'revised' && data.average) {
              model.set('average_rating', data.average)
            }
          })
        }
      }.observes('model.postStream.loaded'),

      showRating: function() {
        if (!this.get('editingTopic')) {return this.get('model.show_ratings')}
        var category = this.site.categories.findProperty('id', this.get('buffered.category_id')),
            tags = this.get('buffered.tags'),
            ratingsVisible = Boolean((category && category.rating_enabled) || (tags && tags.indexOf('rating') > -1));
        if (ratingsVisible !== this.get('buffered.show_ratings')) {
          this.set('refreshAfterTopicEdit', true)
        }
        return ratingsVisible
      }.property('model.show_ratings', 'buffered.category_id', 'buffered.tags'),

      refreshTopic: function() {
        if (!this.get('editingTopic') && this.get('refreshAfterTopicEdit')) {
          this.send('refreshTopic')
          this.set('refreshAfterTopicEdit', false)
        }
      }.observes('editingTopic'),

      toggleCanRate: function() {
        this.toggleProperty('model.can_rate')
      }

    })

    TopicRoute.reopen({
      actions: {
        refreshTopic: function() {
          this.refresh();
        }
      }
    })

    ComposerController.reopen({
      rating: null,
      refreshAfterPost: false,

      // overrides controller methods

      actions: {
        save() {
          var show = this.get('showRating'),
              action = this.get('model.action');
          if (show && action !== Composer.EDIT && !this.get('rating')) {
            return bootbox.alert(I18n.t("composer.select_rating"))
          }
          var topic = this.get('model.topic'),
              post = this.get('model.post');
          if (topic && post && post.get('firstPost') &&
              (action === Composer.EDIT) && (topic.show_ratings !== show)) {
            this.set('refreshAfterPost', true)
          }
          this.save()
        }
      },

      close() {
        this.setProperties({ model: null, lastValidatedAt: null, rating: null });
        if (this.get('refreshAfterPost')) {
          this.send("refreshTopic")
          this.set('refreshAfterPost', false)
        }
      },

      // end of overidden controller methods

      showRating: function() {
        var model = this.get('model')
        if (!model) {return false}
        var topic = model.get('topic'),
            post = model.get('post');
        if ((post && post.get('firstPost')) || !topic) {
          var category = this.site.categories.findProperty('id', model.get('categoryId')),
              tags = model.tags || (topic && topic.tags);
          return Boolean((category && category.rating_enabled) || (tags && tags.indexOf('rating') > -1));
        }
        if (post && !post.get('firstPost') && !topic.can_rate) {
          return Boolean(topic.show_ratings && post.rating && (model.get('action') === Composer.EDIT))
        }
        return topic.can_rate
      }.property('model.topic', 'model.categoryId', 'model.tags', 'model.post'),

      setRating: function() {
        var post = this.get('model.post')
        if (post && this.get('showRating')) {
          this.set('rating', post.rating)
        }
      }.observes('model.post', 'showRating'),

      saveRatingAfterCreating: function() {
        if (!this.get('showRating')
            || !this.get('model.createdPost')) {return}
        this.saveRating(this.get('model.createdPost'))
        this.get('controllers.topic').toggleCanRate()
      }.observes('model.createdPost'),

      saveRatingAfterEditing: function() {
        if (!this.get('showRating')
            || this.get('model.action') !== Composer.EDIT
            || this.get('model.composeState') !== Composer.CLOSED
            || !this.get('model.post')) {return}
        this.saveRating(this.get('model.post'))
      }.observes('model.composeState'),

      saveRating: function(post) {
        var value = this.get('rating'),
            data = { id: post.id, rating: value },
            self = this;
        post.set('rating', value)
        Discourse.ajax("/rating/rate", {
          type: 'POST',
          data: data
        }).catch(function (error) {
          popupAjaxError(error);
        });
      }

    })

    ComposerView.reopen({
      resizeIfShowRating: function() {
        this.resize()
      }.observes('controller.showRating')
    })

    registerUnbound('rating-unbound', function(rating) {
      return new Handlebars.SafeString(renderUnboundRating(rating));
    });

  }
}
