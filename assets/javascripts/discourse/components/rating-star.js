import Component from "@ember/component";
import { not } from "@ember/object/computed";
import { attributeBindings, tagName } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";

@tagName("input")
@attributeBindings("value", "checked:checked", "disabled:disabled")
export default class RatingStar extends Component {
  @not("enabled") disabled;

  willInsertElement() {
    super.willInsertElement(...arguments);
    this.element.type = "radio";
  }

  didRender() {
    super.didRender(...arguments);
    // For IE support
    this.element.value = this.value;
  }

  click() {
    this.set("rating", this.element.value);
  }

  @discourseComputed("rating")
  checked(rating) {
    return this.get("value") <= rating;
  }
}
