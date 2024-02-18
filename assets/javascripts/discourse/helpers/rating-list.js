import { registerRawHelper } from "discourse-common/lib/helpers";
import { ratingListHtml } from "../lib/rating-utilities";
import Handlebars from "handlebars";

registerRawHelper("rating-list", _ratingList);

export default function _ratingList(ratings, opts = {}) {
  return new Handlebars.SafeString(ratingListHtml(ratings, opts));
};
