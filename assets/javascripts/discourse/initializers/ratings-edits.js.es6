import TopicController from 'discourse/controllers/topic';
import Topic from 'discourse/models/topic';
import ComposerController from 'discourse/controllers/composer';
import ComposerView from 'discourse/views/composer';
import Composer from 'discourse/models/composer';
import registerUnbound from 'discourse/helpers/register-unbound';
import renderUnboundRating from 'discourse/plugins/discourse-ratings/lib/render-rating';
import { popupAjaxError } from 'discourse/lib/ajax-error';

export default {
  name: 'ratings-edits',
  initialize(){

    TopicController.reopen({
      
      showRating: function(){
        var category = this.get('model.category'),
            ratingsCategory = category ? category.for_ratings : false;
        if (ratingsCategory) {return ratingsCategory}
        var tags = this.get('model.tags'),
            ratingsTag = tags ? Boolean(tags.indexOf('rating') > -1) : false;
        return ratingsTag
      }.property('model.tags', 'model.category'),

      subscribeToRatingUpdates: function() {
        var model = this.get('model')
        if (!model) {return}
        this.messageBus.subscribe("/topic/" + model.id, function(data) {
          if (data.type === 'revised') {
            model.set('average_rating', data.average)
          }
        })
      }.observes('model.id')

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
          if (topic.archetype === 'private_message' ||
              (topic.posted && this.get('model.action') !== Composer.EDIT)) {
            return false
          }
          var tController = this.get('controllers.topic')
          return tController.get('showRating')
        }
        var categoryId = this.get('model.categoryId'),
            category = this.site.categories.findProperty('id', categoryId);
        if (category) {return category.for_ratings}
        return false
      }.property('model.topic', 'model.categoryId'),

      setRating: function() {
        var post = this.get('model.post')
        if (post && this.get('showRating')) {
          this.set('rating', post.rating)
        }
      }.observes('model.post'),

      saveRatingAfterCreating: function() {
        var post = this.get('model.createdPost');
        if (!post) {return}
        this.saveRating(post)
      }.observes('model.createdPost'),

      saveRatingAfterEditing: function() {
        if (this.get('model.action') === Composer.EDIT
            && this.get('model.composeState') !== Composer.CLOSED) {return}
        var post = this.get('model.post')
        if (post) {
          this.saveRating(post)
        }
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
