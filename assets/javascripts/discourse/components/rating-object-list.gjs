import Component from "@ember/component";
import { action } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import { classNameBindings } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import loadingSpinner from "discourse/helpers/loading-spinner";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import RatingObject from "../models/rating-object";
import RatingObjectItem from "./rating-object-item";

@classNameBindings(":object-types", ":admin-ratings-list", "objectType")
export default class RatingObjectList extends Component {
  @notEmpty("objects") hasObjects;

  @discourseComputed("objectType")
  title(objectType) {
    return i18n(`admin.ratings.${objectType}.title`);
  }

  @discourseComputed("objectType")
  nameLabel(objectType) {
    return i18n(`admin.ratings.${objectType}.name`);
  }

  @discourseComputed("objectType")
  noneLabel(objectType) {
    return i18n(`admin.ratings.${objectType}.none`);
  }

  @action
  newObject() {
    this.get("objects").pushObject({
      name: "",
      types: [],
      isNew: true,
    });
  }

  @action
  addObject(obj) {
    let data = {
      name: obj.name,
      types: obj.types,
      type: this.objectType,
    };

    this.set("loading", true);
    RatingObject.add(data).then((result) => {
      if (result.success) {
        this.refresh();
      } else {
        obj.set("hasError", true);
      }
      this.set("loading", false);
    });
  }

  @action
  updateObject(obj) {
    let data = {
      name: obj.name,
      types: obj.types,
    };
    this.set("loading", true);
    RatingObject.update(this.objectType, data).then((result) => {
      if (result.success) {
        this.refresh();
      } else {
        obj.set("hasError", true);
      }
      this.set("loading", false);
    });
  }

  @action
  destroyObject(obj) {
    if (obj.isNew) {
      this.get("objects").removeObject(obj);
    } else {
      let data = {
        name: obj.name,
      };

      this.set("loading", true);
      RatingObject.destroy(this.objectType, data).then((result) => {
        if (result.success) {
          this.refresh();
        } else {
          obj.set("hasError", true);
        }
        this.set("loading", false);
      });
    }
  }

<template><h3>{{this.title}}</h3>

{{#if this.loading}}
  {{loadingSpinner}}
{{else}}
  {{#if this.hasObjects}}
    <table>
      <thead>
        <tr>
          <th>{{this.nameLabel}}</th>
          <th>{{i18n "admin.ratings.type.title"}}</th>
        </tr>
      </thead>
      <tbody>
        {{#each this.objects as |object|}}
          <RatingObjectItem
            @object={{object}}
            @objects={{this.objects}}
            @objectType={{this.objectType}}
            @ratingTypes={{this.ratingTypes}}
            @addObject={{this.addObject}}
            @updateObject={{this.updateObject}}
            @destroyObject={{this.destroyObject}}
          />
        {{/each}}
      </tbody>
    </table>
  {{else}}
    {{this.noneLabel}}
  {{/if}}
{{/if}}

<div class="admin-ratings-list-controls">
  <DButton @action={{this.newObject}} @label="admin.ratings.type.new" @icon="plus" />
</div></template>}
