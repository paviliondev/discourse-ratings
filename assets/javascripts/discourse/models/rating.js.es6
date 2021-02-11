import EmberObject from "@ember/object";
import { request } from "../lib/rating-utilities";

const Rating = EmberObject.extend();

Rating.reopenClass({
  destroy(type, data) {
    return request("DELETE", `rating/${type}`, data);
  },

  migrate(data) {
    return request("POST", "rating/migrate", data);
  },
});

export default Rating;
