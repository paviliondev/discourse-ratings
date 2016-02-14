var renderUnboundRating = function(rating) {
  var html = ''
  for (var i = 0; i < 5; i++) {
    var value = i + 1,
        checked = value <= rating ? 'checked' : '',
        disabled = disabled ? 'disabled' : '',
        star = '<input type="radio" value="' + value + '" ' + checked + ' disabled><i></i>';
    html = html.concat(star)
  }
  return html;
};

export default renderUnboundRating;
