import { htmlSafe } from "@ember/template";
import { registerRawHelper } from "discourse-common/lib/helpers";
import { ratingListHtml } from "../lib/rating-utilities";

export default function ratingList(ratings, opts = {}) {
  return htmlSafe(ratingListHtml(ratings, opts));
}
registerRawHelper("rating-list", ratingList);
