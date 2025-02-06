import Controller from "@ember/controller";
import { action } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import RatingType from "../models/rating-type";

export default class AdminPluginsRatingsController extends Controller {
  @service dialog;

  @notEmpty("ratingTypes") hasTypes;

  @action
  newType() {
    this.get("ratingTypes").pushObject(
      RatingType.create({
        isNew: true,
        type: "",
        name: "",
      })
    );
  }

  @action
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
  }

  @action
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
  }

  @action
  destroyType(typeObj) {
    if (typeObj.isNew) {
      this.get("ratingTypes").removeObject(typeObj);
    } else {
      this.dialog.yesNoConfirm({
        message: i18n("admin.ratings.type.confirm_destroy"),
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
  }
}
