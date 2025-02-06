import Component from "@ember/component";
import { equal, lt, not, or } from "@ember/object/computed";
import { classNameBindings, tagName } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";

const minTypeLength = 2;
const minNameLength = 2;
const noneType = "none";

@tagName("tr")
@classNameBindings(":rating-type", ":admin-ratings-list-object", "hasError")
export default class RatingType extends Component {
  @lt("type.type.length", minTypeLength) invalidType;
  @lt("type.name.length", minNameLength) invalidName;
  @or("invalidType", "invalidName") addDisabled;
  @equal("type.type", noneType) noneType;
  @not("noneType") showControls;

  didReceiveAttrs() {
    super.didReceiveAttrs();
    this.set("currentName", this.type.name);
  }

  @discourseComputed("invalidName", "type.name", "currentName")
  updateDisabled(invalidName, name, currentName) {
    return invalidName || name === currentName;
  }
}
