import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import TopicRatingTip from "../../components/topic-rating-tip";
@classNames("topic-category-outlet", "topic-tip-container")
export default class TopicTipContainerConnector extends Component {
  static shouldRender(_, context) {
    return context.siteSettings.rating_enabled && context.siteSettings.rating_show_topic_tip;
  }

<template>{{#if this.topic.show_ratings}}
  <TopicRatingTip @details="topic.tip.ratings.details" />
{{/if}}</template>}