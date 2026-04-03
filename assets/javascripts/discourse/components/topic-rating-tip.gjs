import Component from "@ember/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { bind } from "@ember/runloop";
import { classNames } from "@ember-decorators/component";
import $ from "jquery";
import icon from "discourse/helpers/d-icon";
import htmlSafe from "discourse/helpers/html-safe";
import i18n from "discourse/helpers/i18n";

@classNames("topic-rating-tip")
export default class TopicRatingTip extends Component {
  didInsertElement() {
    super.didInsertElement(...arguments);
    $(document).on("click", bind(this, this.documentClick));
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    $(document).off("click", bind(this, this.documentClick));
  }

  documentClick(e) {
    let $element = $(this.element);
    let $target = $(e.target);

    if ($target.closest($element).length < 1 && this._state !== "destroying") {
      this.set("showDetails", false);
    }
  }

  @action
  toggleDetails() {
    this.toggleProperty("showDetails");
  }

<template><a role="button" {{on "click" this.toggleDetails}}>
  {{icon "circle-info"}}
</a>
{{#if this.showDetails}}
  <div class="tip-details">
    {{htmlSafe (i18n this.details)}}
  </div>
{{/if}}</template>}
