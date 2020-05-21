import Category from 'discourse/models/category';
import Site from "discourse/models/site";
import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';

const siteSettings = Discourse.SiteSettings;

let starRatingRaw = function(rating, opts = {}) {
  let content = '';
  for (let i = 0; i < 5; i++) {
    let value = i + 1;
    let checked = value <= rating ? 'checked' : '';
    let disabled = opts.enabled ? '' : ' disabled';
    let star = '';

    if (opts.clickable) {
      star += '<span class="' + checked + disabled + '"></span>';
    } else {
      star += '<input class="' + disabled + '"type="radio" value="' + value + '" ' + checked + disabled + '>';
    }

    star += '<i></i>';
    content = content.concat(star);
  }

  return '<span class="star-rating">' + content + '</span>';
};

function ratingHtml(rating, opts={}) {
  let html = '';
  let title = '';
  let link = null;
    
  const name = typeName(rating.type);
  if (name) {
    html += `<span class="rating-type">${name}</span>`;
    title += `${name} `;
  }
  
  html += starRatingRaw(rating.value);
  title += rating.value;
  
  if (opts.topic) {
    link = opts.topic.url;
    
    if (siteSettings.rating_show_numeric_average) {
      html += `<span class="rating-value">(${rating.value})</span>`;
    }

    if (siteSettings.rating_show_count) {
      let count = rating.count;
      let countLabel = I18n.t('topic.x_rating_count', { count });
      html += `<span class="rating-count">${count} ${countLabel}</span>`;
      title += ` ${count} ${countLabel}`;
    }
  }
  
  if (opts.linkTo && link) {
    return `<a href="${link}" class="rating" title="${title}">${html}</a>`;
  } else {
    return `<div class="rating" title="${title}">${html}</div>`;
  }
}

function ratingListHtml(ratings, opts={}) {
  if (typeof ratings === 'string') {
    try {
      ratings = JSON.parse(ratings);
    } catch(e) {
      console.log(e);
      ratings = null;
    }
  }
  
  if (!ratings) return '';
  
  let html = '';
  
  ratings.forEach(rating => {
    html += ratingHtml(rating, opts);
  });
  
  return `<div class="rating-list">${html}</div>`;
}

function typeName(ratingType) {
  const ratings = Site.currentProp('ratings');
  const type = ratings.types.find(t => t.type === ratingType);
  return type ? type.name : "";
}

function request(type, path='', data={}) {
  return ajax(`/ratings/${path}`, {
    type,
    data
  }).catch(popupAjaxError)
} 

export {
  ratingListHtml,
  typeName,
  request
};
