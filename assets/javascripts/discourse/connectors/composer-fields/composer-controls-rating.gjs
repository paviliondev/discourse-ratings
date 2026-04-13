import Component from "@glimmer/component";
import { action, set } from "@ember/object";
import SelectRating from "../../components/select-rating";

export default class ComposerControlsRatingConnector extends Component {
  @action
  updateRating(rating) {
    const ratings = this.args.model.ratings || [];
    const index = ratings.findIndex((r) => r.type === rating.type);
    if (index === -1) {
      return;
    }
    set(ratings[index], "include", rating.include);
    set(ratings[index], "value", rating.value);
    set(this.args.model, "ratings", ratings);
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
