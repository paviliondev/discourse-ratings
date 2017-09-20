export default Ember.Component.extend({
  tagName: "span",
  classNames: 'star-rating',
  stars: [1, 2, 3, 4, 5],
  enabled: false
});
