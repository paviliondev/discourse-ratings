import Component from "@glimmer/component";
import i18n from "discourse/helpers/i18n";
import RatingDestroy from "./rating-destroy";
import RatingMigrate from "./rating-migrate";

export default class RatingActions extends Component {
<template>
<div class="ratings-action-controls">
  <div class="admin-ratings-action">
    <h3>{{i18n "admin.ratings.migrate.title"}}</h3>

    <div class="description">
      {{i18n "admin.ratings.migrate.description"}}
    </div>

    <div class="controls">
      <RatingMigrate @ratingTypes={{@ratingTypes}} />
    </div>
  </div>

  <div class="admin-ratings-action">
    <h3>{{i18n "admin.ratings.destroy.title"}}</h3>

    <div class="description">
      {{i18n "admin.ratings.destroy.description"}}
    </div>

    <div class="controls">
      <RatingDestroy @ratingTypes={{@ratingTypes}} />
    </div>
  </div>
</div>
</template>}
