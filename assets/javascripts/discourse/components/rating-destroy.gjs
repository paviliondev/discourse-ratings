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
        {{loadingSpinner size="small"}}
      {{/if}}

      {{#if this.destroyMessage}}
        <div class="action-message">
          {{i18n this.destroyMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
