import { classNames } from "@ember-decorators/component";
import MultiSelectComponent from "discourse/select-kit/components/multi-select";
import { selectKitOptions } from "discourse/select-kit/components/select-kit";

@selectKitOptions({
  filterable: true,
})
@classNames("rating-type-chooser")
export default class RatingTypeChooser extends MultiSelectComponent {
  didReceiveAttrs() {
    super.didReceiveAttrs(...arguments);
    if (this.types) {
      this.set("value", this.types.split("|"));
    }
  }

  onChange(value) {
    this.set("types", value.join("|"));
  }
}
