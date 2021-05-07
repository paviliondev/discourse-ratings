import discourseComputed from "discourse-common/utils/decorators";
import Rating from "../models/rating";
import Component from "@ember/component";

export default Component.extend({
  classNames: ["admin-ratings-destroy", "rating-action"],

  @discourseComputed("categoryId", "type")
  destroyDisabled(categoryId, type) {
    return [categoryId, type].any((i) => !i);
  },

  actions: {
    destroyRatings() {
      let data = {
        category_id: this.categoryId,
      };

      this.set("startingDestroy", true);

      Rating.destroy(this.type, data)
        .then((result) => {
          if (result.success) {
            this.set("destroyMessage", "admin.ratings.destroy.started");
          } else {
            this.set(
              "destroyMessage",
              "admin.ratings.error.destroy_failed_to_start"
            );
          }
        })
        .finally(() => this.set("startingDestroy", false));
    },
  },
});
