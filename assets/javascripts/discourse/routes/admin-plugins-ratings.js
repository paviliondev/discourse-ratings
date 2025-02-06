import { A } from "@ember/array";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { all } from "rsvp";
import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";
import RatingObject from "../models/rating-object";
import RatingType from "../models/rating-type";

const noneType = "none";

export default class AdminPluginsRatings extends DiscourseRoute {
  @service router;

  model() {
    return RatingType.all();
  }

  afterModel() {
    return all([this._typesFor("category"), this._typesFor("tag")]);
  }

  setupController(controller, model) {
    let ratingTypes = model || [];

    ratingTypes.unshift({
      type: noneType,
      name: i18n("admin.ratings.type.none_type"),
      isNone: true,
    });

    controller.setProperties({
      ratingTypes: A(ratingTypes.map((t) => RatingType.create(t))),
      categoryTypes: A(this.categoryTypes),
      tagTypes: A(this.tagTypes),
    });
  }

  _typesFor(object) {
    return RatingObject.all(object).then((result) => {
      this.set(`${object}Types`, result);
    });
  }

  @action
  refresh() {
    this.router.refresh();
  }
}
