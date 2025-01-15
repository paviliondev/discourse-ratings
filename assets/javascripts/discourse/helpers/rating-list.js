import { htmlSafe } from "@ember/template";
import { ratingListHtml } from "../lib/rating-utilities";

export default function ratingList(ratings, opts = {}) {
  return htmlSafe(ratingListHtml(ratings, opts));
}
