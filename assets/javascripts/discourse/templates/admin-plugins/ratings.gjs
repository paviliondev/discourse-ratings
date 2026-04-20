import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import { i18n } from "discourse-i18n";
import RatingActions from "../../components/rating-actions";
import RatingObjectList from "../../components/rating-object-list";
import RatingType from "../../components/rating-type";

export default <template>
  <div class="types admin-ratings-list">
    <h3>{{i18n "admin.ratings.type.title"}}</h3>

    {{#if @controller.hasTypes}}
      <table>
        <thead>
          <tr>
            <th>{{i18n "admin.ratings.type.label"}}</th>
            <th>{{i18n "admin.ratings.type.name"}}</th>
          </tr>
        </thead>
        <tbody>
          {{#each @controller.ratingTypes as |type|}}
            <RatingType
              @addType={{@controller.addType}}
              @updateType={{@controller.updateType}}
              @destroyType={{@controller.destroyType}}
              @type={{type}}
            />
          {{/each}}
        </tbody>
      </table>
    {{else}}
      {{i18n "admin.ratings.type.none"}}
    {{/if}}

    <div class="admin-ratings-list-controls">
      <DButton
        @action={{@controller.newType}}
        @label="admin.ratings.type.new"
        @icon="plus"
      />
    </div>
  </div>

  <RatingObjectList
    @objectType="category"
    @objects={{@controller.categoryTypes}}
    @ratingTypes={{@controller.ratingTypes}}
    @refresh={{routeAction "refresh"}}
  />

  <RatingObjectList
    @objectType="tag"
    @objects={{@controller.tagTypes}}
    @ratingTypes={{@controller.ratingTypes}}
    @refresh={{routeAction "refresh"}}
  />

  <RatingActions @ratingTypes={{@controller.ratingTypes}} />
</template>
