import EmberObject from '@ember/object';
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const RatingObject = EmberObject.extend();

function request(type, path='', data={}) {
  return ajax(`/rating/object/${path}`, {
    type,
    data
  }).catch(popupAjaxError)
}

RatingObject.reopenClass({
  all(objectType) {
    return request("GET", objectType);
  },
  
  add(data) {
    return request("POST", '', data);
  },
  
  update(objectType, data) {
    return request("PUT", objectType, data);
  },
  
  destroy(objectType, data) {
    return request("DELETE", objectType, data);
  }
});

export default RatingObject;