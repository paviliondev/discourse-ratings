import Component from "@ember/component";
import { bind } from "@ember/runloop";

export default Component.extend({
  classNames: 'topic-rating-tip',

  didInsertElement() {
    $(document).on('click', bind(this, this.documentClick));
  },

  willDestroyElement() {
    $(document).off('click', bind(this, this.documentClick));
  },

  documentClick(e) {
    let $element = this.$();
    let $target = $(e.target);
    
    if ($target.closest($element).length < 1 && this._state !== 'destroying') {
      this.set('showDetails', false);
    }
  },

  actions: {
    toggleDetails() {
      this.toggleProperty('showDetails');
    }
  }
});
