import TopicController from 'discourse/controllers/topic';
import PostView from 'discourse/views/post';

export default {
  name: 'ratings-edits',
  initialize(){

    TopicController.reopen({
      hasRating: function(){
        var tags = this.get('model.tags'),
            isService = tags ? Boolean(tags.indexOf('service') > -1) : false;
        return isService
      }.property('model.tags')
    })

    // Add logic if ratings are by cateogry instead of tags

  }
}
