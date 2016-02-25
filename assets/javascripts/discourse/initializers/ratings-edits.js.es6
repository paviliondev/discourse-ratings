import TopicController from 'discourse/controllers/topic';
import Topic from 'discourse/models/topic';
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
      api.decorateWidget('poster-name:after', function(helper) {
        var rating = helper.getModel().get('rating'),
            html = new Handlebars.SafeString(renderUnboundRating(rating));
        if (helper.widget.container.lookup('controller:topic').showRating) {
          return helper.rawHtml(`${html}`);
        }
      })
    });

    TopicController.reopen({
      showRating: false,

      showRating: function(){
        var category = this.get('model.category');
        if (category && category.for_ratings) {
          this.subscribeToRatingUpdates()
          return true
        }
        var tags = this.get('model.tags')
        if (tags && tags.indexOf('rating') > -1) {
          this.subscribeToRatingUpdates()
          return true
        }
        return false
      }.property('model.tags', 'model.category'),

      subscribeToRatingUpdates: function() {
        var model = this.get('model')
        this.messageBus.subscribe("/topic/" + model.id, function(data) {
          if (data.type === 'revised') {
            if (model.get('average_rating')) {
              model.set('average_rating', data.average)
            }
          }
        })
      }

    })

    ComposerController.reopen({

      // overrides controller method

      close() {
        this.setProperties({ model: null, lastValidatedAt: null, rating: null });
      },

      //

      showRating: function() {
        var topic = this.get('model.topic')
        if (topic) {
          if (topic.posted && this.get('model.action') !== Composer.EDIT) {
            return false
          }
          return this.get('controllers.topic.showRating')
        } else {
          var categoryId = this.get('model.categoryId'),
              category = this.site.categories.findProperty('id', categoryId);
          if (category) {return category.for_ratings}
          return false
        }
      }.property('model.topic', 'model.categoryId'),

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
