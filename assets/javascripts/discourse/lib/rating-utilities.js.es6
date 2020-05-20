import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import Category from 'discourse/models/category';
import Site from "discourse/models/site";

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
  let link = null;
    
  const name = typeName(rating.type);
  if (name) {
    html += `<span>${name}</span>`;
  }
  
  html += starRatingRaw(rating.value);
  
  if (opts.topic) {
    link = opts.topic.url;
    
    if (siteSettings.rating_show_numeric_average) {
      html += `<span class="exact-rating">(${rating.value})</span>`;
    }

    if (siteSettings.rating_show_count) {
      let countLabel = I18n.t('topic.x_rating_count', {
        count: opts.topic.rating_count
      });
      let countContent = rating.rating_count + countLabel;
      html += `<span class="rating-count">${countContent}</span>`;
    }
  }
  
  if (opts.linkTo && link) {
    return `<a href="${link}" class="rating">${html}</a>`;
  } else {
    return `<div class="rating">${html}</div>`;
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

export {
  ratingListHtml,
  typeName
};
