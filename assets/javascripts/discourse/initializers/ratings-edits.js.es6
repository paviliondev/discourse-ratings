import TopicController from 'discourse/controllers/topic';

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

  }
}
