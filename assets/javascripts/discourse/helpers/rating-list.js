import { trustHTML } from "@ember/template";
import { ratingListHtml } from "../lib/rating-utilities";

export default function ratingList(ratings, opts = {}) {
  return trustHTML(ratingListHtml(ratings, opts));
}
