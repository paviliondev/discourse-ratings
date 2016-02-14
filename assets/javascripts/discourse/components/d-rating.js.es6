import { popupAjaxError } from 'discourse/lib/ajax-error';
import Topic from 'discourse/models/topic';

export default Ember.Component.extend({
  tagName: "span",
  classNames: 'rating',
  stars: [1, 2, 3, 4, 5],
  enabled: false,

  rate: function() {
    var post = this.get('post')
    if (!post) {return}
    var value = this.get('rating'),
        topic = this.get('topic');
    post.set('rating', value)
    Discourse.ajax("/rating/rate", {
      type: 'POST',
      data: { id: post.id, rating: value }
    }).then((result) => {
      if (topic){topic.set('average_rating', result)}
    }).catch(function (error) {
      popupAjaxError(error);
    });
  }.observes('rating', 'post'),

})
