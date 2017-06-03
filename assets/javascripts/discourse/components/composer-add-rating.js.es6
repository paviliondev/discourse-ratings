import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Component.extend({
  classNames: ['composer-button'],
  
  @computed('model.composeState', 'model.currentType', 'model.showRating')
  showRating(state, type, show) {
    return state === 'd-full' && type === 'rating' && show;
  }
})
