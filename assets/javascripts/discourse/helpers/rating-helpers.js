import Handlebars from "handlebars";
import { registerUnbound } from "discourse-common/lib/helpers";
import { ratingListHtml } from "../lib/rating-utilities";

registerUnbound("rating-list", function (ratings, opts = {}) {
  return new Handlebars.SafeString(ratingListHtml(ratings, opts));
});
