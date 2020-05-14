import Component from "@ember/component";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  init(){
    this._super(...arguments);
    this.set('type', this.type || {});
  },

  actions: {
    add(){
      ajax('/rating/add_type', {
        type: "POST",
        data: {
          type_name: this.type.value
        }
      }).then(response => {
        this.added(this.value);
      }).catch(popupAjaxError)
    },
    update(){

    },
    delete(){
      ajax('/rating/delete_type', {
        type: "DELETE",
        data: {
          type_id: this.get('type.id')
        }
      }).then(response => {
        console.log(response)
      }).catch(popupAjaxError)
    }
  }
})