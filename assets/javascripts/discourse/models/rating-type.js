import EmberObject from "@ember/object";
import { request } from "../lib/rating-utilities";

export default class RatingType extends EmberObject {
  static all() {
    return request("GET", "rating-type");
  }

  static add(data) {
    return request("POST", "rating-type", data);
  }

  static update(type, data) {
    return request("PUT", `rating-type/${type}`, data);
  }

  static destroy(type) {
    return request("DELETE", `rating-type/${type}`);
  }
}
