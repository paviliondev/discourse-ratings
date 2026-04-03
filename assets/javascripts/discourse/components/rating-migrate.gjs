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

const noneType = "none";

@classNames("rating-action-controls")
export default class RatingMigrate extends Component {
  @discourseComputed("categoryId", "toType", "fromType")
  migrateDisabled(categoryId, toType, fromType) {
    return (
      [categoryId, toType, fromType].any((i) => !i) ||
      (toType !== noneType && fromType !== noneType)
    );
  }

  @action
  migrate() {
    let data = {
      category_id: this.categoryId,
      type: this.fromType,
      new_type: this.toType,
    };

    this.set("startingMigration", true);

    Rating.migrate(data)
      .then((result) => {
        if (result.success) {
          this.set("migrationMessage", "admin.ratings.migrate.started");
        } else {
          this.set(
            "migrationMessage",
            "admin.ratings.error.migration_failed_to_start"
          );
        }
      })
      .finally(() => this.set("startingMigration", false));
  }

  @action
  updateCategory(categoryId) {
    this.set("categoryId", categoryId);
  }

  @action
  updateFromType(fromType) {
    this.set("fromType", fromType);
  }

  @action
  updateToType(toType) {
    this.set("toType", toType);
  }

<template><CategoryChooser @value={{this.categoryId}} @onChange={{this.updateCategory}} />

<ComboBox
  @value={{this.fromType}}
  @content={{this.ratingTypes}}
  @valueProperty="type"
  @onChange={{this.updateFromType}}
  @options={{hash none="admin.ratings.type.select"}}
/>

<ComboBox
  @value={{this.toType}}
  @content={{this.ratingTypes}}
  @valueProperty="type"
  @onChange={{this.updateToType}}
  @options={{hash none="admin.ratings.type.select"}}
/>

<DButton @action={{this.migrate}} @label="admin.ratings.migrate.btn" @disabled={{this.migrateDisabled}} />

{{#if this.startingMigration}}
  {{loadingSpinner size="small"}}
{{/if}}

{{#if this.migrationMessage}}
  <div class="action-message">
    {{i18n this.migrationMessage}}
  </div>
{{/if}}</template>}
