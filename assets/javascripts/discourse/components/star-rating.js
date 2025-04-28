import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";

@tagName("span")
@classNames("star-rating")
export default class StarRating extends Component {
  stars = [1, 2, 3, 4, 5];
  enabled = false;
}
