import discourseComputed from "discourse-common/utils/decorators";
import { typeName } from '../lib/rating-utilities';

export default Ember.Component.extend({
  tagName: "div",
  classNames: ["rating-container"],

  @discourseComputed('rating.type')
  typeName(ratingType) {
    return typeName(ratingType);
  },

  actions: {
    updateRating(){
      this.updateRating(this.rating);
    }
  }
});
