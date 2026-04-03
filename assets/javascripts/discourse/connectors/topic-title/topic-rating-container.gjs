import Component from "@glimmer/component";
import ratingList from "../../helpers/rating-list";

export default class TopicRatingContainerConnector extends Component {
  static shouldRender(_, context) {
    return context.siteSettings.rating_enabled;
  }

<template><div class="topic-title-outlet topic-rating-container">{{#if @model.show_ratings}}
  {{ratingList @model.ratings topic=@model}}
{{/if}}</div></template>}