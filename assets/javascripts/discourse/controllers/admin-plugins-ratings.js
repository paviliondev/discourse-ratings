import Controller from "@ember/controller";
import { notEmpty } from "@ember/object/computed";
import { service } from "@ember/service";
import I18n from "I18n";
import RatingType from "../models/rating-type";

export default Controller.extend({
  dialog: service(),
  hasTypes: notEmpty("ratingTypes"),

  actions: {
    newType() {
      this.get("ratingTypes").pushObject(
        RatingType.create({
          isNew: true,
          type: "",
          name: "",
        })
      );
    },

    addType(typeObj) {
      let data = {
        type: typeObj.type,
        name: typeObj.name,
      };

      this.set("loading", true);
      RatingType.add(data).then((result) => {
        if (result.success) {
          this.send("refresh");
        } else {
          typeObj.set("hasError", true);
          this.set("loading", false);
        }
      });
    },

    updateType(typeObj) {
      let data = {
        name: typeObj.name,
      };

      this.set("loading", true);
      RatingType.update(typeObj.type, data).then((result) => {
        if (result.success) {
          this.send("refresh");
        } else {
          typeObj.set("hasError", true);
          this.set("loading", false);
        }
      });
    },

    destroyType(typeObj) {
      if (typeObj.isNew) {
        this.get("ratingTypes").removeObject(typeObj);
      } else {
        this.dialog.yesNoConfirm({
          message: I18n.t("admin.ratings.type.confirm_destroy"),
          didConfirm: () => {
            this.set("loading", true);
            RatingType.destroy(typeObj.type).then((response) => {
              if (response.success) {
                this.send("refresh");
              } else {
                typeObj.set("hasError", true);
                this.set("loading", false);
              }
            });
          },
        });
      }
    },
  },
});
