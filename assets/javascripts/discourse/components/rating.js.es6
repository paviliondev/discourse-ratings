import { popupAjaxError } from 'discourse/lib/ajax-error';

export default Ember.Component.extend({
  tagName: "span",
  classNames: 'rating',

  didInsertElement: function(){
    var t = this
    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$('input:radio').off().on('change', function(){
        t.rate(this.value)
      })
    })
  },

  rating: function(){
    var rating = [],
        ratingNum = this.get('ratingNum'),
        ratingNum = ratingNum ? ratingNum : 0,
        maxStars = 5,
        disabled = this.get('allowRating') ? false : true;

    for (var i = 0; i < maxStars; i++) {
      rating.push({
        value: i + 1,
        disabled: disabled,
        checked: i + 1 <= ratingNum ? true : false,
      })
    }

    return rating
  }.property('ratingNum'),

  rate: function(value) {
    var postId = this.get('postId')
    Ember.run(this, function(){
      console.log(postId, value)
      Discourse.ajax("/service/rate", {
        type: 'POST',
        data: {
          id: postId,
          rating: value
        }
      }).catch(popupAjaxError);
    });
  },

  willClearRender: function(){
    var t = this
    this.$('input:radio').off('change', function(){
      t.rate(this.value)
    })
  }

})
