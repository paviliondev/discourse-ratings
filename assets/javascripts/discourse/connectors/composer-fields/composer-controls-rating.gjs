import Component from "@ember/component";
import { set } from "@ember/object";
import { action } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import SelectRating from "../../components/select-rating";

@classNames("composer-fields-outlet", "composer-controls-rating")
export default class ComposerControlsRatingConnector extends Component {
  @action
  updateRating(rating) {
    const ratings = this.get("model.ratings") || [];
    const index = ratings.findIndex(r => r.type === rating.type);
    set(ratings[index], "value", rating.value);
    this.set("model.ratings", ratings);
  }

<template>
  {{#if this.model.showRatings}}
    {{#each this.model.ratings as |rating|}}
      <SelectRating @rating={{rating}} @updateRating={{this.updateRating}} />
    {{/each}}
  {{/if}}
</template>}