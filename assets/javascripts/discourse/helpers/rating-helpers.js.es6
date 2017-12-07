import { registerUnbound } from 'discourse-common/lib/helpers';
import { unboundRating } from '../lib/rating-utilities';

registerUnbound('rating-unbound', function(rating) {
  return new Handlebars.SafeString(unboundRating(rating));
});

registerUnbound('average-rating', function(topic) {
  let html = `(${topic.average_rating}`;
  if (Discourse.SiteSettings.rating_show_count && topic.rating_count) {
    html += `/${topic.rating_count}`;
  }
  html += ')';
  return new Handlebars.SafeString(html);
});
