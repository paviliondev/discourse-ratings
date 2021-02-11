import Component from "@ember/component";
import { lt, or, not, equal } from "@ember/object/computed";
import { computed } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

const minTypeLength = 2;
const minNameLength = 2;
const noneType = "none";

export default Component.extend({
  tagName: "tr",
  classNameBindings: [":rating-type", ":admin-ratings-list-object", "hasError"],
  invalidType: lt("type.type.length", minTypeLength),
  invalidName: lt("type.name.length", minNameLength),
  addDisabled: or("invalidType", "invalidName"),
  noneType: equal("type.type", noneType),
  showControls: not("noneType"),

  didReceiveAttrs() {
    this.set("currentName", this.type.name);
  },

  @discourseComputed("invalidName", "type.name", "currentName")
  updateDisabled(invalidName, name, currentName) {
    return invalidName || name === currentName;
  },
});
