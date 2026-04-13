import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action,set } from "@ember/object";
import DButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";

const minTypeLength = 2;
const minNameLength = 2;
const noneType = "none";

export default class RatingType extends Component {
  @tracked currentTypeValue;
  @tracked currentTypeName;

  originalName;

  constructor(owner, args) {
    super(owner, args);
    this.currentTypeValue = args.type.type || "";
    this.currentTypeName = args.type.name || "";
    this.originalName = args.type.name || "";
  }

  get invalidType() {
    return this.currentTypeValue.length < minTypeLength;
  }

  get invalidName() {
    return this.currentTypeName.length < minNameLength;
  }

  get addDisabled() {
    return this.invalidType || this.invalidName;
  }

  get showControls() {
    return this.currentTypeValue !== noneType;
  }

  get updateDisabled() {
    return this.invalidName || this.currentTypeName === this.originalName;
  }

  @action
  updateTypeValue(e) {
    const val = e.target.value;
    set(this.args.type, "type", val);
    this.currentTypeValue = val;
  }

  @action
  updateTypeName(e) {
    const val = e.target.value;
    set(this.args.type, "name", val);
    this.currentTypeName = val;
  }

<template>
<tr class="rating-type admin-ratings-list-object">
  <td>
  {{#if @type.isNew}}
    <input
      type="text"
      value={{this.currentTypeValue}}
      placeholder={{i18n "admin.ratings.type.type_placeholder"}}
      {{on "input" this.updateTypeValue}}
    />
  {{else}}
    {{@type.type}}
  {{/if}}
</td>

<td>
  {{#if @type.isNone}}
    {{i18n "admin.ratings.type.none_type_description"}}
  {{else}}
    <input
      type="text"
      value={{this.currentTypeName}}
      placeholder={{i18n "admin.ratings.type.name_placeholder"}}
      {{on "input" this.updateTypeName}}
    />
  {{/if}}
</td>

<td class="type-controls">
  {{#if this.showControls}}
    {{#if @type.isNew}}
      <DButton
        class="btn-primary"
        @action={{@addType}}
        @actionParam={{@type}}
        @label="admin.ratings.type.add"
        @icon="plus"
        @disabled={{this.addDisabled}}
      />
    {{else}}
      <DButton
        class="btn-primary"
        @action={{@updateType}}
        @actionParam={{@type}}
        @label="admin.ratings.type.update"
        @icon="check"
        @disabled={{this.updateDisabled}}
      />
    {{/if}}

    <DButton @action={{@destroyType}} @actionParam={{@type}} @icon="xmark" />
  {{/if}}
</td>
</tr>
</template>}
