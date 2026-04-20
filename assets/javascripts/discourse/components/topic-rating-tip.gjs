import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import icon from "discourse/helpers/d-icon";
import htmlSafe from "discourse/helpers/html-safe";
import i18n from "discourse/helpers/i18n";

export default class TopicRatingTip extends Component {
  @tracked showDetails = false;

  element = null;

  @action
  setup(element) {
    this.element = element;
    document.addEventListener("click", this.documentClick);
  }

  @action
  teardown() {
    document.removeEventListener("click", this.documentClick);
  }

  @action
  documentClick(e) {
    if (!this.element || this.isDestroying || this.isDestroyed) {
      return;
    }

    if (!this.element.contains(e.target)) {
      this.showDetails = false;
    }
  }

  @action
  toggleDetails() {
    this.showDetails = !this.showDetails;
  }

  <template>
    <div
      class="topic-rating-tip"
      {{didInsert this.setup}}
      {{willDestroy this.teardown}}
    >
      <a role="button" {{on "click" this.toggleDetails}}>
        {{icon "circle-info"}}
      </a>
      {{#if this.showDetails}}
        <div class="tip-details">
          {{htmlSafe (i18n @details)}}
        </div>
      {{/if}}</div>
  </template>
}
