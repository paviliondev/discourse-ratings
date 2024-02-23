import Component from "@ember/component";
import { observes } from "discourse-common/utils/decorators";

export default Component.extend({
  tagName: "div",
  classNames: ["rating-container"],

  @observes("rating.include")
  removeOnUncheck() {
    if (!this.rating.include) {
      this.set("rating.value", 0);
      this.updateRating(this.rating);
    }
  },

  actions: {
    updateRating() {
      this.updateRating(this.rating);
    },
  },
});
