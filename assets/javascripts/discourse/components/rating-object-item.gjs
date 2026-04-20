import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { action, set } from "@ember/object";
import DButton from "discourse/components/d-button";
import categoryBadge from "discourse/helpers/category-badge";
import discourseTag from "discourse/helpers/discourse-tag";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";
import CategoryChooser from "select-kit/components/category-chooser";
import MultiSelect from "select-kit/components/multi-select";
import TagChooser from "select-kit/components/tag-chooser";

export default class RatingObjectItem extends Component {
  @tracked error = null;
  @tracked category = null;
  @tracked tag = null;
  @tracked objectName;
  @tracked objectTypes;

  originalName;
  originalTypes;

  constructor(owner, args) {
    super(owner, args);
    const object = args.object;

    this.originalName = object.name;
    this.originalTypes = [...(object.types || [])];
    this.objectName = object.name;
    this.objectTypes = [...(object.types || [])];

    if (object.name) {
      if (args.objectType === "category") {
        const slugPath = object.name.split("/");
        this.category = Category.findBySlugPath(slugPath);
      }
      if (args.objectType === "tag") {
        this.tag = object.name;
      }
    }
  }

  get isCategory() {
    return this.args.objectType === "category";
  }

  get isTag() {
    return this.args.objectType === "tag";
  }

  get rowClass() {
    let cls = "rating-object admin-ratings-list-object";
    if (this.error) {
      cls += " hasError";
    }
    return cls;
  }

  get saveDisabled() {
    return (
      !!this.error ||
      !this.objectName ||
      !this.objectTypes?.length ||
      (this.objectName === this.originalName &&
        JSON.stringify(this.objectTypes) === JSON.stringify(this.originalTypes))
    );
  }

  @action
  updateCategory(categoryId) {
    const category = Category.findById(categoryId);
    const slug = Category.slugFor(category);
    const objects = this.args.objects || [];

    if (objects.every((o) => o.name !== slug)) {
      set(this.args.object, "name", slug);
      this.objectName = slug;
      this.category = category;
      this.error = null;
    } else {
      this.error = i18n("admin.ratings.error.object_already_exists", {
        objectType: this.args.objectType,
      });
    }
  }

  @action
  updateTag(tags) {
    const objects = this.args.objects || [];
    const tag = tags[0];

    if (objects.every((o) => o.name !== tag)) {
      set(this.args.object, "name", tag);
      this.objectName = tag;
      this.tag = tag;
      this.error = null;
    } else {
      this.error = i18n("admin.ratings.error.object_already_exists", {
        objectType: this.args.objectType,
      });
    }
  }

  @action
  updateTypes(types) {
    set(this.args.object, "types", types);
    this.objectTypes = types;
  }

  <template>
    <tr class={{this.rowClass}}>
      <td>
        {{#if @object.isNew}}
          {{#if this.isCategory}}
            <CategoryChooser
              @value={{this.category.id}}
              @onChange={{this.updateCategory}}
            />
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
          @value={{this.objectTypes}}
          @content={{@ratingTypes}}
          @valueProperty="type"
          @onChange={{this.updateTypes}}
        />
      </td>

      <td class="type-controls">
        {{#if @object.isNew}}
          <DButton
            class="btn-primary"
            @action={{@addObject}}
            @actionParam={{@object}}
            @label="admin.ratings.type.add"
            @icon="plus"
            @disabled={{this.saveDisabled}}
          />
        {{else}}
          <DButton
            class="btn-primary"
            @action={{@updateObject}}
            @actionParam={{@object}}
            @label="admin.ratings.type.update"
            @icon="check"
            @disabled={{this.saveDisabled}}
          />
        {{/if}}

        <DButton
          @action={{@destroyObject}}
          @actionParam={{@object}}
          @icon="xmark"
        />
      </td>

      {{#if this.error}}
        <span class="error">{{this.error}}</span>
      {{/if}}
    </tr>
  </template>
}
