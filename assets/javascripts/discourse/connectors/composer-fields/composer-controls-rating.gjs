import Component from "@glimmer/component";
import { action } from "@ember/object";
import SelectRating from "../../components/select-rating";

export default class ComposerControlsRatingConnector extends Component {
  @action
  updateRating(rating) {
    this.args.model.setRating(rating.type, rating.value, rating.include);
  }

  <template>
    <div class="composer-fields-outlet composer-controls-rating">
      {{#if @model.showRatings}}
        {{#each @model.ratings as |rating|}}
          <SelectRating
            @rating={{rating}}
            @updateRating={{this.updateRating}}
          />
        {{/each}}
      {{/if}}
    </div>
  </template>
}
