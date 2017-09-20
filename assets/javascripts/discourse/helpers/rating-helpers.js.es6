import { registerUnbound } from 'discourse-common/lib/helpers';
import unboundRating from 'discourse/plugins/discourse-ratings/discourse/lib/rating-utilities';

registerUnbound('rating-unbound', function(rating) {
  return new Handlebars.SafeString(unboundRating(rating));
});
