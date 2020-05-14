import Component from "@ember/component";
import RatingType from '../models/rating-type';
import { lt, or, alias } from "@ember/object/computed";

const minSlugLength = 2;
const minNameLength = 2;

export default Component.extend({
  classNameBindings: [':rating-type', 'hasError'],
  tagName: 'tr',
  invalidSlug: lt('type.slug.length', minSlugLength),
  invalidName: lt('type.name.length', minNameLength),
  addDisabled: or('invalidSlug', 'invalidName'),
  updateDisabled: alias('invalidName')
})