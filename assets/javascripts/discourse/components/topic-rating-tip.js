import Component from "@ember/component";
import { bind } from "@ember/runloop";
import $ from "jquery";

export default Component.extend({
  classNames: "topic-rating-tip",

  didInsertElement() {
    this._super(...arguments);
    $(document).on("click", bind(this, this.documentClick));
  },

  willDestroyElement() {
    this._super(...arguments);
    $(document).off("click", bind(this, this.documentClick));
  },

  documentClick(e) {
    let $element = $(this.element);
    let $target = $(e.target);

    if ($target.closest($element).length < 1 && this._state !== "destroying") {
      this.set("showDetails", false);
    }
  },

  actions: {
    toggleDetails() {
      this.toggleProperty("showDetails");
    },
  },
});
