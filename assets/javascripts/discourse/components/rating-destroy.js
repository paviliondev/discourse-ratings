import Component from "@ember/component";
import { action } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";
import Rating from "../models/rating";

@classNames("admin-ratings-destroy", "rating-action")
export default class RatingDestroy extends Component {
  @discourseComputed("categoryId", "type")
  destroyDisabled(categoryId, type) {
    return [categoryId, type].any((i) => !i);
  }

  @action
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
  }
}
