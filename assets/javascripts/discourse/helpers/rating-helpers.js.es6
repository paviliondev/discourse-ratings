import { registerUnbound } from 'discourse-common/lib/helpers';
import { starRatingRaw } from '../lib/rating-utilities';

registerUnbound('star-rating-raw', function(rating, opts) {
  return new Handlebars.SafeString(starRatingRaw(rating, opts));
});

registerUnbound('average-rating', function(average, args = {}) {
  let html = `${average}`;
  if (Discourse.SiteSettings.rating_show_count && args.count) {
    html += ` – ${args.count} ${I18n.t('topic.x_rating_count', { count: args.count })}`;
  }
  return new Handlebars.SafeString(html);
});
