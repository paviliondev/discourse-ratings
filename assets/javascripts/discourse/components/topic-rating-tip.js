import Component from "@ember/component";
import { action } from "@ember/object";
import { bind } from "@ember/runloop";
import { classNames } from "@ember-decorators/component";
import $ from "jquery";

@classNames("topic-rating-tip")
export default class TopicRatingTip extends Component {
  didInsertElement() {
    super.didInsertElement(...arguments);
    $(document).on("click", bind(this, this.documentClick));
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    $(document).off("click", bind(this, this.documentClick));
  }

  documentClick(e) {
    let $element = $(this.element);
    let $target = $(e.target);

    if ($target.closest($element).length < 1 && this._state !== "destroying") {
      this.set("showDetails", false);
    }
  }

  @action
  toggleDetails() {
    this.toggleProperty("showDetails");
  }
}
