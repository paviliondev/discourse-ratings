import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import ratingList from "../../helpers/rating-list";
@classNames("topic-title-outlet", "topic-rating-container")
export default class TopicRatingContainerConnector extends Component {
  static shouldRender(_, context) {
    return context.siteSettings.rating_enabled;
  }

<template>{{#if this.model.show_ratings}}
  {{ratingList this.model.ratings topic=this.model}}
{{/if}}</template>}