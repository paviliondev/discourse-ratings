import { default as computed } from 'ember-addons/ember-computed-decorators';
import Component from "@ember/component";

export default Component.extend({
  tagName: "input",
  disabled: Ember.computed.not('enabled'),
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

  @computed('rating')
  checked(rating) {
    return this.get("value") <= rating;
  }
});
