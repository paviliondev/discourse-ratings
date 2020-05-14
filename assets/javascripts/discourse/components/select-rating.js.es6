import discourseComputed from "discourse-common/utils/decorators";

export default Ember.Component.extend({
  tagName: "div",
  classNames: ["rating-container"],
  showIncludeRating: true,
  init(){
    this._super(...arguments);
  },
  @discourseComputed('ratingType')
  ratingTypeName(ratingType){
    let type = this.site.rating_types.find(type => type.id === ratingType);
    return type ? type.value : "";
  },

  actions: {
    updateRating(rating){
      this.updateRating(this.ratingType, rating);
    }
  }
});
