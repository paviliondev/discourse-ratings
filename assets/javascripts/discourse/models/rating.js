import EmberObject from "@ember/object";
import { request } from "../lib/rating-utilities";

export default class Rating extends EmberObject {
  static destroy(type, data) {
    return request("DELETE", `rating/${type}`, data);
  }

  static migrate(data) {
    return request("POST", "rating/migrate", data);
  }
}
