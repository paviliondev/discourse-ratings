import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import CategoryChooser from "discourse/select-kit/components/category-chooser";
import ComboBox from "discourse/select-kit/components/combo-box";
import DButton from "discourse/ui-kit/d-button";
import dLoadingSpinner from "discourse/ui-kit/helpers/d-loading-spinner";
import { i18n } from "discourse-i18n";
import Rating from "../models/rating";

export default class RatingDestroy extends Component {
  @tracked categoryId = null;
  @tracked type = null;
  @tracked startingDestroy = false;
  @tracked destroyMessage = null;

  get destroyDisabled() {
    return !this.categoryId || !this.type;
  }

  @action
  destroyRatings() {
    let data = {
      category_id: this.categoryId,
    };

    this.startingDestroy = true;

    Rating.destroy(this.type, data)
      .then((result) => {
        if (result.success) {
          this.destroyMessage = "admin.ratings.destroy.started";
        } else {
          this.destroyMessage = "admin.ratings.error.destroy_failed_to_start";
        }
      })
      .finally(() => (this.startingDestroy = false));
  }

  @action
  updateCategory(categoryId) {
    this.categoryId = categoryId;
  }

  @action
  updateType(type) {
    this.type = type;
  }

  <template>
    <div class="admin-ratings-destroy rating-action">
      <CategoryChooser
        @value={{this.categoryId}}
        @onChange={{this.updateCategory}}
      />

      <ComboBox
        @value={{this.type}}
        @content={{@ratingTypes}}
        @valueProperty="type"
        @onChange={{this.updateType}}
        @options={{hash none="admin.ratings.type.select"}}
      />

      <DButton
        @action={{this.destroyRatings}}
        @label="admin.ratings.destroy.btn"
        @disabled={{this.destroyDisabled}}
      />

      {{#if this.startingDestroy}}
        {{dLoadingSpinner size="small"}}
      {{/if}}

      {{#if this.destroyMessage}}
        <div class="action-message">
          {{i18n this.destroyMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
