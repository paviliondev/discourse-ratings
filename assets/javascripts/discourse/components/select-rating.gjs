import Component, { Input } from "@ember/component";
import { action } from "@ember/object";
import { classNames, tagName } from "@ember-decorators/component";
import { observes } from "@ember-decorators/object";
import i18n from "discourse/helpers/i18n";
import StarRating from "./star-rating";

@tagName("div")
@classNames("rating-container")
export default class SelectRating extends Component {
  @observes("rating.include")
  removeOnUncheck() {
    if (!this.rating.include) {
      this.set("rating.value", 0);
      this.updateRating(this.rating);
    }
  }

  @action
  triggerUpdateRating(value) {
    this.set("rating.value", value);
    this.updateRating(this.rating);
  }

<template><Input @type="checkbox" @checked={{this.rating.include}} class="include-rating" />

<span>
  {{#if this.rating.typeName}}
    {{this.rating.typeName}}
  {{else}}
    {{i18n "composer.your_rating"}}
  {{/if}}
</span>

  <StarRating @enabled={{this.rating.include}} @rating={{this.rating.value}} @onChange={{this.triggerUpdateRating}} /></template>}
