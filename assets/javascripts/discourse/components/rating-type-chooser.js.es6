import MultiSelectComponent from "select-kit/components/multi-select";

export default MultiSelectComponent.extend({
  classNames: ["rating-type-chooser"],

  selectKitOptions: {
    filterable: true,
  },

  didReceiveAttrs() {
    this._super(...arguments);
    if (this.types) {
      this.set("value", this.types.split("|"));
    }
  },

  onChange(value) {
    this.set("types", value.join("|"));
  },
});
