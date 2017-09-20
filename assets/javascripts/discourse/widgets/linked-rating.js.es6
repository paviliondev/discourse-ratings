import { createWidget } from 'discourse/widgets/widget';
import DiscourseURL from 'discourse/lib/url';

export default createWidget('linked-rating', {
  tagName: 'span.linked-rating',

  html(attrs) {
    return this.attach('star-rating', {rating: attrs.rating, disabled: attrs.disabled});
  },

  click() {
    DiscourseURL.routeTo(this.attrs.href);
  }
});
