import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  classNames: ['btn-composer'],

  @computed('model.currentType', 'model.showRating')
  showRating(type, show) {
    return type === 'rating' && show;
  }
})
