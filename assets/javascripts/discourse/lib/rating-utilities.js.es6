import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import Category from 'discourse/models/category';
import Site from "discourse/models/site";

let ratingEnabled = function(type, tags, categoryId) {
  let category = Category.findById(categoryId),
      catEnabled = category && category.rating_enabled,
      tagEnabled = tags && tags.filter(function(t){
                      return Discourse.SiteSettings.rating_tags.split('|').indexOf(t) !== -1;
                   }).length > 0,
      typeEnabled = type === 'rating';

  return catEnabled || tagEnabled || typeEnabled;
};

let removeRating = function(postId) {
  return ajax("/rating/remove", {
    type: 'POST',
    data: {
      post_id: postId,
    }
  }).then(function (result, error) {
    if (error) {
      popupAjaxError(error);
    }
  });
};

let editRating = function(postId, rating) {
  return ajax("/rating/rate", {
    type: 'POST',
    data: {
      post_id: postId,
      rating: rating
    }
  }).then(function (result, error) {
    if (error) {
      popupAjaxError(error);
    }
  });
};

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

let starRatingArrayRaw = function(ratings, opts = {}) {
  let ratingsString = "<div>";
  if(ratings ) {
    if(Array.isArray(ratings)) {
      ratings.forEach(rating => {
        ratingsString += starRatingRaw(rating.rating) + "<br/>";
      });
    } else {
      ratingsString += starRatingRaw(ratings.rating) + "<br/>";
    }
  }
  ratingsString += "</div>";

  return ratingsString;
}

function typeName(ratingType) {
  const ratingTypes = Site.currentProp('rating_types');
  const type = ratingTypes.find(t => t.slug === ratingType);
  return type ? type.name : "";
}

export {
  ratingEnabled,
  removeRating,
  editRating,
  starRatingRaw,
  starRatingArrayRaw,
  typeName
};
