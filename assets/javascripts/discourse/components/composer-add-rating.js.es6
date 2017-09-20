import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  @computed('model.subtype', 'model.showRating')
  showRating(subtype, show) {
    return subtype === 'rating' && show;
  }
});
