import { createWidget } from "discourse/widgets/widget";

export default createWidget("rating-star", {
  tagName: "input",

  buildAttributes(attrs) {
    let result = {
      type: "radio",
      value: attrs.value,
    };
    if (attrs.checked) {
      result["checked"] = true;
    }
    if (attrs.disabled) {
      result["disabled"] = true;
    }
    return result;
  },

  html() {
    return;
  },
});
