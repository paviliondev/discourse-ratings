import EmberObject from "@ember/object";
import { request } from "../lib/rating-utilities";

export default class RatingObject extends EmberObject {
  static all(type) {
    return request("GET", `object/${type}`);
  }

  static add(data) {
    return request("POST", "object", data);
  }

  static update(type, data) {
    return request("PUT", `object/${type}`, data);
  }

  static destroy(type, data) {
    return request("DELETE", `object/${type}`, data);
  }
}
