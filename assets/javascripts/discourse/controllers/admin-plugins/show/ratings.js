import Controller from "@ember/controller";
import { action, computed } from "@ember/object";
import { service } from "@ember/service";
import { isEmpty } from "@ember/utils";
import { i18n } from "discourse-i18n";
import RatingType from "../../../models/rating-type";

export default class AdminPluginsShowRatingsController extends Controller {
  @service dialog;

  @computed("ratingTypes.length")
  get hasTypes() {
    return !isEmpty(this.ratingTypes);
  }

  @action
  newType() {
    this.set("ratingTypes", [
      ...this.ratingTypes,
      RatingType.create({
        isNew: true,
        type: "",
        name: "",
      }),
    ]);
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
      this.set(
        "ratingTypes",
        this.ratingTypes.filter((type) => type !== typeObj)
      );
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
