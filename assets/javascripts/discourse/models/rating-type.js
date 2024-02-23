import EmberObject from "@ember/object";
import { request } from "../lib/rating-utilities";

const RatingType = EmberObject.extend();

RatingType.reopenClass({
  all() {
    return request("GET", "rating-type");
  },

  add(data) {
    return request("POST", "rating-type", data);
  },

  update(type, data) {
    return request("PUT", `rating-type/${type}`, data);
  },

  destroy(type) {
    return request("DELETE", `rating-type/${type}`);
  },
});

export default RatingType;
