import Component from "@ember/component";
import { equal, lt, not, or } from "@ember/object/computed";
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
    this._super();
    this.set("currentName", this.type.name);
  },

  @discourseComputed("invalidName", "type.name", "currentName")
  updateDisabled(invalidName, name, currentName) {
    return invalidName || name === currentName;
  },
});
