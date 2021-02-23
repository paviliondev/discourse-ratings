import { registerUnbound } from "discourse-common/lib/helpers";
import { ratingListHtml } from "../lib/rating-utilities";
import Handlebars from "handlebars";

registerUnbound("rating-list", function (ratings, opts = {}) {
  return new Handlebars.SafeString(ratingListHtml(ratings, opts));
});
