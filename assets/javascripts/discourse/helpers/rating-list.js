import { ratingListHtml } from "../lib/rating-utilities";
import Handlebars from "handlebars";

export default function _ratingList(ratings, opts = {}) {
  return new Handlebars.SafeString(ratingListHtml(ratings, opts));
};
