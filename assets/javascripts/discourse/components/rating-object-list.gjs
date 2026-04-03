import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { set } from "@ember/object";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import loadingSpinner from "discourse/helpers/loading-spinner";
import { i18n } from "discourse-i18n";
import RatingObject from "../models/rating-object";
import RatingObjectItem from "./rating-object-item";

export default class RatingObjectList extends Component {
  @tracked loading = false;

  get hasObjects() {
    return !!this.args.objects?.length;
  }

  get title() {
    return i18n(`admin.ratings.${this.args.objectType}.title`);
  }

  get nameLabel() {
    return i18n(`admin.ratings.${this.args.objectType}.name`);
  }

  get noneLabel() {
    return i18n(`admin.ratings.${this.args.objectType}.none`);
  }

  @action
  newObject() {
    this.args.objects.pushObject({
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
      type: this.args.objectType,
    };

    this.loading = true;
    RatingObject.add(data).then((result) => {
      if (result.success) {
        this.args.refresh();
      } else {
        set(obj, "hasError", true);
      }
      this.loading = false;
    });
  }

  @action
  updateObject(obj) {
    let data = {
      name: obj.name,
      types: obj.types,
    };
    this.loading = true;
    RatingObject.update(this.args.objectType, data).then((result) => {
      if (result.success) {
        this.args.refresh();
      } else {
        set(obj, "hasError", true);
      }
      this.loading = false;
    });
  }

  @action
  destroyObject(obj) {
    if (obj.isNew) {
      this.args.objects.removeObject(obj);
    } else {
      let data = {
        name: obj.name,
      };

      this.loading = true;
      RatingObject.destroy(this.args.objectType, data).then((result) => {
        if (result.success) {
          this.args.refresh();
        } else {
          set(obj, "hasError", true);
        }
        this.loading = false;
      });
    }
  }

<template>
<div class="object-types admin-ratings-list {{@objectType}}">
  <h3>{{this.title}}</h3>

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
          {{#each @objects as |object|}}
            <RatingObjectItem
              @object={{object}}
              @objects={{@objects}}
              @objectType={{@objectType}}
              @ratingTypes={{@ratingTypes}}
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
  </div>
</div>
</template>}
