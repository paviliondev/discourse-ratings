import EmberObject from '@ember/object';
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const RatingType = EmberObject.extend();
const ratingPath = "/rating/rating-type";

function request(path, type, data={}) {
  return ajax(path, {
    type,
    data
  }).catch(popupAjaxError)
}

RatingType.reopenClass({
  all() {
    return request(ratingPath, "GET");
  },

  add(type) {
    return request(ratingPath, "POST", { type });
  },
  
  update(type) {
    return request(`${ratingPath}/${type.slug}`, "PUT", { type });
  },

  destroy(type) {
    return request(`${ratingPath}/${type.slug}`, "DELETE");
  }
});

export default RatingType;