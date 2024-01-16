import Component from "@ember/component";
import { equal } from "@ember/object/computed";
import Category from "discourse/models/category";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";

export default Component.extend({
  classNameBindings: [
    ":rating-object",
    ":admin-ratings-list-object",
    "error:hasError",
  ],
  tagName: "tr",
  isCategory: equal("objectType", "category"),
  isTag: equal("objectType", "tag"),
  error: null,

  didReceiveAttrs() {
    this._super();
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
  },

  @discourseComputed("error", "object.name", "object.types.[]")
  saveDisabled(error, objectName, objectTypes) {
    return (
      error ||
      !objectName ||
      !objectTypes.length ||
      (objectName === this.currentName &&
        JSON.stringify(objectTypes) === JSON.stringify(this.currentTypes))
    );
  },

  actions: {
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
          I18n.t("admin.ratings.error.object_already_exists", {
            objectType: this.objectType,
          })
        );
      }
    },

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
          I18n.t("admin.ratings.error.object_already_exists", {
            objectType: this.objectType,
          })
        );
      }
    },
  },
});
