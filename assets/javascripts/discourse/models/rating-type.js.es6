import EmberObject from '@ember/object';
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const RatingType = EmberObject.extend();

function request(type, path='', data={}) {
  return ajax(`/rating/rating-type/${path}`, {
    type,
    data
  }).catch(popupAjaxError)
}

RatingType.reopenClass({
  all() {
    return request("GET");
  },

  add(type) {
    return request("POST", { type });
  },
  
  update(type) {
    return request("PUT", type.slug, { type });
  },

  destroy(type) {
    return request("DELETE", type.slug);
  }
});

export default RatingType;