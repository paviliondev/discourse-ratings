import Controller from "@ember/controller";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Controller.extend({
  init(){
    this._super(...arguments);
    ajax('/rating/list_types').then(response => {
      this.set('types', response);
    }).catch(popupAjaxError)
  },

  actions: {
    add(){
      this.set('newType', true);
    },
    addToList(value){
      this.types.push({value: value});
      this.newType = false;
    }
  }
})