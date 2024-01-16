import { h } from "virtual-dom";
import { createWidget } from "discourse/widgets/widget";

export default createWidget("star-rating", {
  tagName: "span.star-rating",

  html(attrs) {
    const stars = [1, 2, 3, 4, 5];
    let contents = [];

    stars.forEach((s) => {
      let checked = s <= attrs.rating;
      contents.push(
        this.attach("rating-star", {
          value: s,
          checked,
          disabled: attrs.disabled,
        }),
        h("i")
      );
    });

    return contents;
  },
});
