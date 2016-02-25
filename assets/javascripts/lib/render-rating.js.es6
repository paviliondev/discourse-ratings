var renderUnboundRating = function(rating) {
  var stars = ''
  for (var i = 0; i < 5; i++) {
    var value = i + 1,
        checked = value <= rating ? 'checked' : '',
        disabled = disabled ? 'disabled' : '',
        star = '<input type="radio" value="' + value + '" ' + checked + ' disabled><i></i>';
    stars = stars.concat(star)
  }
  return '<span class="rating">' + stars + '</span>';
};

export default renderUnboundRating;
