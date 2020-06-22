import discourseComputed from "discourse-common/utils/decorators";
import { not } from "@ember/object/computed";
import Component from "@ember/component";

export default Component.extend({
  tagName: "input",
  disabled: not('enabled'),
  attributeBindings: [ "value", "checked:checked", "disabled:disabled"],

  willInsertElement() {
    this.$().prop('type', 'radio');
  },

  didRender() {
    // For IE support
    this.element.value = this.value;
  },

  click() {
    this.set("rating", this.$().val());
  },

  @discourseComputed('rating')
  checked(rating) {
    return this.get("value") <= rating;
  }
});
