import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import i18n from "discourse/helpers/i18n";
import RatingDestroy from "./rating-destroy";
import RatingMigrate from "./rating-migrate";

@classNames("ratings-action-controls")
export default class RatingActions extends Component {<template><div class="admin-ratings-action">
  <h3>{{i18n "admin.ratings.migrate.title"}}</h3>

  <div class="description">
    {{i18n "admin.ratings.migrate.description"}}
  </div>

  <div class="controls">
    <RatingMigrate @ratingTypes={{this.ratingTypes}} />
  </div>
</div>

<div class="admin-ratings-action">
  <h3>{{i18n "admin.ratings.destroy.title"}}</h3>

  <div class="description">
    {{i18n "admin.ratings.destroy.description"}}
  </div>

  <div class="controls">
    <RatingDestroy @ratingTypes={{this.ratingTypes}} />
  </div>
</div></template>}
