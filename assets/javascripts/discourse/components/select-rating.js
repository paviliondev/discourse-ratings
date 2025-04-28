import Component from "@ember/component";
import { action } from "@ember/object";
import { classNames, tagName } from "@ember-decorators/component";
import { observes } from "@ember-decorators/object";

@tagName("div")
@classNames("rating-container")
export default class SelectRating extends Component {
  @observes("rating.include")
  removeOnUncheck() {
    if (!this.rating.include) {
      this.set("rating.value", 0);
      this.updateRating(this.rating);
    }
  }

  @action
  triggerUpdateRating() {
    this.updateRating(this.rating);
  }
}
