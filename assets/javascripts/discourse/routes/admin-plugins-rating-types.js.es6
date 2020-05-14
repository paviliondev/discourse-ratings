import DiscourseRoute from "discourse/routes/discourse";
import { A } from "@ember/array";
import RatingType from '../models/rating-type';

export default DiscourseRoute.extend({
  model() {
    return RatingType.all();
  },
  
  setupController(controller, model) {
    controller.set('ratingTypes', A(
      model.map(t => RatingType.create(t))
    ));
  },
  
  actions: {
    refresh() {
      this.refresh();
    }
  }
})