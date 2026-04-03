import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";
import loadingSpinner from "discourse/helpers/loading-spinner";
import discourseComputed from "discourse/lib/decorators";
import CategoryChooser from "select-kit/components/category-chooser";
import ComboBox from "select-kit/components/combo-box";
import Rating from "../models/rating";

@classNames("admin-ratings-destroy", "rating-action")
export default class RatingDestroy extends Component {
  @discourseComputed("categoryId", "type")
  destroyDisabled(categoryId, type) {
    return [categoryId, type].any((i) => !i);
  }

  @action
  destroyRatings() {
    let data = {
      category_id: this.categoryId,
    };

    this.set("startingDestroy", true);

    Rating.destroy(this.type, data)
      .then((result) => {
        if (result.success) {
          this.set("destroyMessage", "admin.ratings.destroy.started");
        } else {
          this.set(
            "destroyMessage",
            "admin.ratings.error.destroy_failed_to_start"
          );
        }
      })
      .finally(() => this.set("startingDestroy", false));
  }

  @action
  updateCategory(categoryId) {
    this.set("categoryId", categoryId);
  }

  @action
  updateType(type) {
    this.set("type", type);
  }

<template><CategoryChooser @value={{this.categoryId}} @onChange={{this.updateCategory}} />

<ComboBox
  @value={{this.type}}
  @content={{this.ratingTypes}}
  @valueProperty="type"
  @onChange={{this.updateType}}
  @options={{hash none="admin.ratings.type.select"}}
/>

<DButton @action={{this.destroyRatings}} @label="admin.ratings.destroy.btn" @disabled={{this.destroyDisabled}} />

{{#if this.startingDestroy}}
  {{loadingSpinner size="small"}}
{{/if}}

{{#if this.destroyMessage}}
  <div class="action-message">
    {{i18n this.destroyMessage}}
  </div>
{{/if}}</template>}
