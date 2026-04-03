import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import RatingStar from "./rating-star";

@tagName("span")
@classNames("star-rating")
export default class StarRating extends Component {
  stars = [1, 2, 3, 4, 5];
  enabled = false;
<template>{{#each this.stars as |star|}}
  <RatingStar @value={{star}} @rating={{this.rating}} @enabled={{this.enabled}} @onChange={{this.onChange}} /><i></i>
{{/each}}</template>}
