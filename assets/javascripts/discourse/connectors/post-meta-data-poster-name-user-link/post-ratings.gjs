import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import { ratingListHtml } from "../../lib/rating-utilities";

export default class PostRatings extends Component {
  get showRatings() {
    return this.args.post.ratings && this.args.post.ratings.length > 0;
  }

  get ratingList() {
    return htmlSafe(ratingListHtml(this.args.post.ratings));
  }

  <template>
    {{yield}}
    {{#if this.showRatings}}
      <span class="post-ratings">{{this.ratingList}}</span>
    {{/if}}
  </template>
}
