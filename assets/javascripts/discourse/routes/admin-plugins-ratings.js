import { A } from "@ember/array";
import { all } from "rsvp";
import DiscourseRoute from "discourse/routes/discourse";
import I18n from "I18n";
import RatingObject from "../models/rating-object";
import RatingType from "../models/rating-type";

const noneType = "none";

export default DiscourseRoute.extend({
  model() {
    return RatingType.all();
  },

  afterModel() {
    return all([this._typesFor("category"), this._typesFor("tag")]);
  },

  setupController(controller, model) {
    let ratingTypes = model || [];

    ratingTypes.unshift({
      type: noneType,
      name: I18n.t("admin.ratings.type.none_type"),
      isNone: true,
    });

    controller.setProperties({
      ratingTypes: A(ratingTypes.map((t) => RatingType.create(t))),
      categoryTypes: A(this.categoryTypes),
      tagTypes: A(this.tagTypes),
    });
  },

  _typesFor(object) {
    return RatingObject.all(object).then((result) => {
      this.set(`${object}Types`, result);
    });
  },

  actions: {
    refresh() {
      this.refresh();
    },
  },
});
