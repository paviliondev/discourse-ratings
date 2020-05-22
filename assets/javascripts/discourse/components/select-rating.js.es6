import discourseComputed from "discourse-common/utils/decorators";
import Component from "@ember/component";

export default Component.extend({
  tagName: "div",
  classNames: ["rating-container"],

  actions: {
    updateRating(){
      this.updateRating(this.rating);
    }
  }
});
