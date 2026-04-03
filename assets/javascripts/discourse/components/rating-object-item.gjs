import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { equal } from "@ember/object/computed";
import { classNameBindings, tagName } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import categoryBadge from "discourse/helpers/category-badge";
import discourseTag from "discourse/helpers/discourse-tag";
import discourseComputed from "discourse/lib/decorators";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";
import CategoryChooser from "select-kit/components/category-chooser";
import MultiSelect from "select-kit/components/multi-select";
import TagChooser from "select-kit/components/tag-chooser";

@classNameBindings(
  ":rating-object",
  ":admin-ratings-list-object",
  "error:hasError"
)
@tagName("tr")
export default class RatingObjectItem extends Component {
  @equal("objectType", "category") isCategory;
  @equal("objectType", "tag") isTag;

  error = null;

  didReceiveAttrs() {
    super.didReceiveAttrs();
    const object = this.object;

    this.setProperties({
      currentName: object.name,
      currentTypes: object.types,
    });

    if (object.name) {
      if (this.isCategory) {
        const slugPath = object.name.split("/");
        this.set("category", Category.findBySlugPath(slugPath));
      }

      if (this.isTag) {
        this.set("tag", object.name);
      }
    }
  }

  @discourseComputed("error", "object.name", "object.types.[]")
  saveDisabled(error, objectName, objectTypes) {
    return (
      error ||
      !objectName ||
      !objectTypes.length ||
      (objectName === this.currentName &&
        JSON.stringify(objectTypes) === JSON.stringify(this.currentTypes))
    );
  }

  @action
  updateCategory(categoryId) {
    const category = Category.findById(categoryId);
    const slug = Category.slugFor(category);
    const objects = this.objects || [];

    if (objects.every((o) => o.name !== slug)) {
      this.setProperties({
        "object.name": slug,
        category,
        error: null,
      });
    } else {
      this.set(
        "error",
        i18n("admin.ratings.error.object_already_exists", {
          objectType: this.objectType,
        })
      );
    }
  }

  @action
  updateTag(tags) {
    const objects = this.objects || [];
    const tag = tags[0];

    if (objects.every((o) => o.name !== tag)) {
      this.setProperties({
        "object.name": tag,
        tag,
        error: null,
      });
    } else {
      this.set(
        "error",
        i18n("admin.ratings.error.object_already_exists", {
          objectType: this.objectType,
        })
      );
    }
  }

  @action
  updateTypes(types) {
    this.set("object.types", types);
  }

<template><td>
  {{#if this.object.isNew}}
    {{#if this.isCategory}}
      <CategoryChooser @value={{this.category.id}} @onChange={{this.updateCategory}} />
    {{/if}}
    {{#if this.isTag}}
      <TagChooser
        @tags={{this.tag}}
        @everyTag={{true}}
        @excludeSynonyms={{true}}
        @maximum={{1}}
        @onChange={{this.updateTag}}
        @options={{hash none="select_kit.default_header_text"}}
      />
    {{/if}}
  {{else}}
    {{#if this.isCategory}}
      {{categoryBadge this.category}}
    {{/if}}
    {{#if this.isTag}}
      {{discourseTag this.tag}}
    {{/if}}
  {{/if}}
</td>

<td>
  <MultiSelect
    @value={{this.object.types}}
    @content={{this.ratingTypes}}
    @valueProperty="type"
    @onChange={{this.updateTypes}}
  />
</td>

<td class="type-controls">
  {{#if this.object.isNew}}
    <DButton
      @class="btn-primary"
      @action={{this.addObject}}
      @actionParam={{this.object}}
      @label="admin.ratings.type.add"
      @icon="plus"
      @disabled={{this.saveDisabled}}
    />
  {{else}}
    <DButton
      @class="btn-primary"
      @action={{this.updateObject}}
      @actionParam={{this.object}}
      @label="admin.ratings.type.update"
      @icon="check"
      @disabled={{this.saveDisabled}}
    />
  {{/if}}

  <DButton @action={{this.destroyObject}} @actionParam={{this.object}} @icon="xmark" />
</td>

{{#if this.error}}
  <span class="error">{{this.error}}</span>
{{/if}}</template>}
