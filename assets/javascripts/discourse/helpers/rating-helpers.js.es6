import { registerUnbound } from 'discourse-common/lib/helpers';
import { ratingListHtml } from '../lib/rating-utilities';

registerUnbound('rating-list', function(rating, opts={}) {
  return new Handlebars.SafeString(ratingListHtml(rating, opts));
});
