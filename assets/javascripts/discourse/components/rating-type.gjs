import Component, { Input } from "@ember/component";
import { equal, lt, not, or } from "@ember/object/computed";
import { classNameBindings, tagName } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import i18n from "discourse/helpers/i18n";
import discourseComputed from "discourse/lib/decorators";

const minTypeLength = 2;
const minNameLength = 2;
const noneType = "none";

@tagName("tr")
@classNameBindings(":rating-type", ":admin-ratings-list-object", "hasError")
export default class RatingType extends Component {
  @lt("type.type.length", minTypeLength) invalidType;
  @lt("type.name.length", minNameLength) invalidName;
  @or("invalidType", "invalidName") addDisabled;
  @equal("type.type", noneType) noneType;
  @not("noneType") showControls;

  didReceiveAttrs() {
    super.didReceiveAttrs();
    this.set("currentName", this.type.name);
  }

  @discourseComputed("invalidName", "type.name", "currentName")
  updateDisabled(invalidName, name, currentName) {
    return invalidName || name === currentName;
  }

<template><td>
  {{#if this.type.isNew}}
    <Input @value={{this.type.type}} @placeholder={{i18n "admin.ratings.type.type_placeholder"}} />
  {{else}}
    {{this.type.type}}
  {{/if}}
</td>

<td>
  {{#if this.type.isNone}}
    {{i18n "admin.ratings.type.none_type_description"}}
  {{else}}
    <Input @value={{this.type.name}} @placeholder={{i18n "admin.ratings.type.name_placeholder"}} />
  {{/if}}
</td>

<td class="type-controls">
  {{#if this.showControls}}
    {{#if this.type.isNew}}
      <DButton
        @class="btn-primary"
        @action={{this.addType}}
        @actionParam={{this.type}}
        @label="admin.ratings.type.add"
        @icon="plus"
        @disabled={{this.addDisabled}}
      />
    {{else}}
      <DButton
        @class="btn-primary"
        @action={{this.updateType}}
        @actionParam={{this.type}}
        @label="admin.ratings.type.update"
        @icon="check"
        @disabled={{this.updateDisabled}}
      />
    {{/if}}

    <DButton @action={{this.destroyType}} @actionParam={{this.type}} @icon="xmark" />
  {{/if}}
</td></template>}
