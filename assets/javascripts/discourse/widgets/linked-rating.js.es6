import { createWidget } from 'discourse/widgets/widget';
import DiscourseURL from 'discourse/lib/url';
import { h } from 'virtual-dom';

export default createWidget('linked-rating', {
  tagName: 'span.linked-rating',

  html(attrs, state) {
    return this.attach('star-rating', {rating: attrs.rating, disabled: attrs.disabled})
  },

  click() {
    DiscourseURL.routeTo(this.attrs.href);
  }
})
