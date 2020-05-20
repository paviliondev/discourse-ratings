import Component from "@ember/component";
import { lt, or } from "@ember/object/computed";
import { computed } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

const minTypeLength = 2;
const minNameLength = 2;

export default Component.extend({
  classNameBindings: [':rating-type', ':admin-ratings-list-object', 'hasError'],
  tagName: 'tr',
  invalidType: lt('type.type.length', minTypeLength),
  invalidName: lt('type.name.length', minNameLength),
  addDisabled: or('invalidType', 'invalidName'),
  
  didReceiveAttrs() {
    this.set('currentName', this.type.name)
  },
  
  @discourseComputed('invalidName', 'type.name', 'currentName')
  updateDisabled(invalidName, name, currentName) {
    return invalidName || (name === currentName);
  }
})