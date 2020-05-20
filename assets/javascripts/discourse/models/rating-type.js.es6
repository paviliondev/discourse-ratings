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

  add(data) {
    return request("POST", '', data);
  },
  
  update(type, data) {
    return request("PUT", type, data);
  },

  destroy(type) {
    return request("DELETE", type);
  },
  
  migrate(data) {
    return request("POST", "migrate", data);
  }
});

export default RatingType;