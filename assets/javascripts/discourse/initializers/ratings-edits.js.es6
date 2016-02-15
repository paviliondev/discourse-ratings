import TopicController from 'discourse/controllers/topic';
import ComposerController from 'discourse/controllers/composer';
import ComposerView from 'discourse/views/composer';
import registerUnbound from 'discourse/helpers/register-unbound';
import renderUnboundRating from 'discourse/plugins/discourse-ratings/lib/render-rating';

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
      }.property('model.tags', 'model.category')
    })

    ComposerController.reopen({
      showRating: function() {
        var topic = this.get('model.topic')
        if (topic) {
          if (topic.archetype === 'private_message' || topic.posted) {return false}
          var tController = this.get('controllers.topic')
          return tController.get('showRating')
        }
        var categoryId = this.get('model.categoryId'),
            category = this.site.categories.findProperty('id', categoryId);
        if (category) {return category.for_ratings}
        return false
      }.property('model.topic', 'model.categoryId')
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
