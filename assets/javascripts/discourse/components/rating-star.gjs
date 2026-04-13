import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";

export default class RatingStar extends Component {
  get checked() {
    return Number(this.args.value) <= Number(this.args.rating || 0);
  }

  get disabled() {
    return !this.args.enabled;
  }

  @action
  select() {
    this.args.onChange?.(Number(this.args.value));
  }

  <template>
    <input
      type="radio"
      value={{@value}}
      checked={{this.checked}}
      disabled={{this.disabled}}
      {{on "click" this.select}}
    />
  </template>
}
