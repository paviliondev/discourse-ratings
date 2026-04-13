import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action,set } from "@ember/object";
import i18n from "discourse/helpers/i18n";
import StarRating from "./star-rating";

export default class SelectRating extends Component {
  @action
  updateInclude(event) {
    const include = event.target.checked;
    set(this.args.rating, "include", include);

    if (!include) {
      set(this.args.rating, "value", 0);
    }

    this.args.updateRating(this.args.rating);
  }

  @action
  triggerUpdateRating(value) {
    set(this.args.rating, "value", value);
    this.args.updateRating(this.args.rating);
  }

<template><div class="rating-container">
  <input
    type="checkbox"
    checked={{@rating.include}}
    class="include-rating"
    {{on "change" this.updateInclude}}
  />

<span>
  {{#if @rating.typeName}}
    {{@rating.typeName}}
  {{else}}
    {{i18n "composer.your_rating"}}
  {{/if}}
</span>

  <StarRating @enabled={{@rating.include}} @rating={{@rating.value}} @onChange={{this.triggerUpdateRating}} />
</div></template>}
