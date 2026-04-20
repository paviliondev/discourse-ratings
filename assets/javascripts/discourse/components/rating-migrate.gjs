import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";
import loadingSpinner from "discourse/helpers/loading-spinner";
import CategoryChooser from "select-kit/components/category-chooser";
import ComboBox from "select-kit/components/combo-box";
import Rating from "../models/rating";

const noneType = "none";

export default class RatingMigrate extends Component {
  @tracked categoryId = null;
  @tracked fromType = null;
  @tracked toType = null;
  @tracked startingMigration = false;
  @tracked migrationMessage = null;

  get migrateDisabled() {
    return (
      !this.categoryId ||
      !this.toType ||
      !this.fromType ||
      (this.toType !== noneType && this.fromType !== noneType)
    );
  }

  @action
  migrate() {
    let data = {
      category_id: this.categoryId,
      type: this.fromType,
      new_type: this.toType,
    };

    this.startingMigration = true;

    Rating.migrate(data)
      .then((result) => {
        if (result.success) {
          this.migrationMessage = "admin.ratings.migrate.started";
        } else {
          this.migrationMessage =
            "admin.ratings.error.migration_failed_to_start";
        }
      })
      .finally(() => (this.startingMigration = false));
  }

  @action
  updateCategory(categoryId) {
    this.categoryId = categoryId;
  }

  @action
  updateFromType(fromType) {
    this.fromType = fromType;
  }

  @action
  updateToType(toType) {
    this.toType = toType;
  }

  <template>
    <div class="rating-action-controls">
      <CategoryChooser
        @value={{this.categoryId}}
        @onChange={{this.updateCategory}}
      />

      <ComboBox
        @value={{this.fromType}}
        @content={{@ratingTypes}}
        @valueProperty="type"
        @onChange={{this.updateFromType}}
        @options={{hash none="admin.ratings.type.select"}}
      />

      <ComboBox
        @value={{this.toType}}
        @content={{@ratingTypes}}
        @valueProperty="type"
        @onChange={{this.updateToType}}
        @options={{hash none="admin.ratings.type.select"}}
      />

      <DButton
        @action={{this.migrate}}
        @label="admin.ratings.migrate.btn"
        @disabled={{this.migrateDisabled}}
      />

      {{#if this.startingMigration}}
        {{loadingSpinner size="small"}}
      {{/if}}

      {{#if this.migrationMessage}}
        <div class="action-message">
          {{i18n this.migrationMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
