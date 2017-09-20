import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';

let ratingEnabled = function(type, tags, categoryId) {
  let category = Discourse.Category.findById(categoryId),
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
      id: postId,
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
      id: postId,
      rating: rating
    }
  }).then(function (result, error) {
    if (error) {
      popupAjaxError(error);
    }
  });
};

let unboundRating = function(rating) {
  var stars = '';
  for (var i = 0; i < 5; i++) {
    var value = i + 1,
        checked = value <= rating ? 'checked' : '',
        disabled = disabled ? 'disabled' : '',
        star = '<input type="radio" value="' + value + '" ' + checked + ' disabled><i></i>';
    stars = stars.concat(star);
  }
  return '<span class="star-rating">' + stars + '</span>';
};

export { ratingEnabled, removeRating, editRating, unboundRating };
