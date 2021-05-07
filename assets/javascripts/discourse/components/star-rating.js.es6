import Component from "@ember/component";

export default Component.extend({
  tagName: "span",
  classNames: "star-rating",
  stars: [1, 2, 3, 4, 5],
  enabled: false,
});
