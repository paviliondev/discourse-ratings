import Component from "@ember/component";
import { notEmpty } from "@ember/object/computed";
import discourseComputed from "discourse-common/utils/decorators";
import I18n from "I18n";
import RatingObject from "../models/rating-object";

export default Component.extend({
  classNameBindings: [":object-types", ":admin-ratings-list", "objectType"],
  hasObjects: notEmpty("objects"),

  @discourseComputed("objectType")
  title(objectType) {
    return I18n.t(`admin.ratings.${objectType}.title`);
  },

  @discourseComputed("objectType")
  nameLabel(objectType) {
    return I18n.t(`admin.ratings.${objectType}.name`);
  },

  @discourseComputed("objectType")
  noneLabel(objectType) {
    return I18n.t(`admin.ratings.${objectType}.none`);
  },

  actions: {
    newObject() {
      this.get("objects").pushObject({
        name: "",
        types: [],
        isNew: true,
      });
    },

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
    },

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
    },

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
    },
  },
});
