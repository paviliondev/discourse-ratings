import discourseComputed from "discourse-common/utils/decorators";
import { typeName } from '../lib/rating-utilities';

export default Ember.Component.extend({
  tagName: "div",
  classNames: ["rating-container"],
  showIncludeRating: true,

  @discourseComputed('ratingType')
  typeName(ratingType) {
    return typeName(ratingType);
  },

  actions: {
    updateRating(rating){
      this.updateRating(this.ratingType, rating);
    }
  }
});
