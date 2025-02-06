import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { getOwnerWithFallback } from "discourse/lib/get-owner";
import { i18n } from "discourse-i18n";

let starRatingRaw = function (rating, opts = {}) {
  let content = "";
  for (let i = 0; i < 5; i++) {
    let value = i + 1;
    let checked = value <= rating ? "checked" : "";
    let disabled = opts.enabled ? "" : " disabled";
    let star = "";

    if (opts.clickable) {
      star += '<span class="' + checked + disabled + '"></span>';
    } else {
      star +=
        '<input class="' +
        disabled +
        '"type="radio" value="' +
        value +
        '" ' +
        checked +
        disabled +
        ">";
    }

    star += "<i></i>";
    content = content.concat(star);
  }

  return '<span class="star-rating">' + content + "</span>";
};

function ratingHtml(rating, opts = {}) {
  let html = "";
  let title = "";
  let link = null;

  const name = rating.type_name;
  if (name) {
    html += `<span class="rating-type">${name}</span>`;
    title += `${name} `;
  }

  let value = Math.round(rating.value * 10) / 10;
  html += starRatingRaw(value);
  title += value;

  if (opts.topic) {
    link = opts.topic.url;
    const siteSettings = getOwnerWithFallback(this).lookup(
      "service:site-settings"
    );

    if (siteSettings.rating_show_numeric_average) {
      html += `<span class="rating-value">(${value})</span>`;
    }

    if (siteSettings.rating_show_count) {
      let count = rating.count;
      let countLabel = i18n("topic.x_rating_count", { count });
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

function ratingListHtml(ratings, opts = {}) {
  if (typeof ratings === "string") {
    try {
      ratings = JSON.parse(ratings);
    } catch {
      ratings = null;
    }
  }

  if (!ratings) {
    return "";
  }

  let html = "";

  ratings.forEach((rating) => {
    let showRating = opts.topic ? rating.count > 0 : rating.weight > 0;

    if (showRating) {
      html += ratingHtml(rating, opts);
    }
  });

  return `<div class="rating-list">${html}</div>`;
}

function request(type, path = "", data = {}) {
  return ajax(`/ratings/${path}`, {
    type,
    data,
  }).catch(popupAjaxError);
}

export { ratingListHtml, request };
