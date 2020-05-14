import { registerUnbound } from 'discourse-common/lib/helpers';
import { starRatingRaw } from '../lib/rating-utilities';
import { typeName } from '../lib/rating-utilities';
import I18n from 'I18n';

const siteSettings = Discourse.SiteSettings;

registerUnbound('topic-rating', function(rating, topic) {
  let content = '';
  
  const name = typeName(rating.type);
  if (name) {
    content += `<span>${name}</span>`;
  }
  
  content += starRatingRaw(rating);

  if (siteSettings.rating_show_exact_average) {
    content += `<span class="exact-rating">(${rating.average_rating})</span>`;
  }

  if (siteSettings.rating_show_count) {
    let countLabel = I18n.t('topic.x_rating_count', { count: topic.rating_count });
    content += `<span class="rating-count">${rating.rating_count}${countLabel}</span>`;
  }
  
  return new Handlebars.SafeString(`<div class="topic-rating">${content}</div>`);
});

registerUnbound('star-rating-raw', function(rating, opts) {
  return new Handlebars.SafeString(starRatingRaw(rating, opts));
});

registerUnbound('average-rating', function(average, args = {}) {
  let html = `${average}`;
  if (siteSettings.rating_show_count && args.count) {
    html += ` – ${args.count} ${I18n.t('topic.x_rating_count', { count: args.count })}`;
  }
  return new Handlebars.SafeString(html);
});
