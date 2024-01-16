import Component from "@ember/component";
import { not } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  tagName: "input",
  disabled: not("enabled"),
  attributeBindings: ["value", "checked:checked", "disabled:disabled"],

  willInsertElement() {
    this._super(...arguments);
    this.element.type = "radio";
  },

  didRender() {
    this._super(...arguments);
    // For IE support
    this.element.value = this.value;
  },

  click() {
    this.set("rating", this.element.value);
  },

  @discourseComputed("rating")
  checked(rating) {
    return this.get("value") <= rating;
  },
});
