import EmberObject from "@ember/object";
import { request } from "../lib/rating-utilities";

const RatingObject = EmberObject.extend();

RatingObject.reopenClass({
  all(type) {
    return request("GET", `object/${type}`);
  },

  add(data) {
    return request("POST", "object", data);
  },

  update(type, data) {
    return request("PUT", `object/${type}`, data);
  },

  destroy(type, data) {
    return request("DELETE", `object/${type}`, data);
  },
});

export default RatingObject;
