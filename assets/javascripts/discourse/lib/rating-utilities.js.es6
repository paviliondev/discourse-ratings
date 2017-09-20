let ratingEnabled = function(type, tags, categoryId) {
  let category = Discourse.Category.findById(categoryId),
      catEnabled = category && category.rating_enabled,
      tagEnabled = tags && tags.filter(function(t){
                      return Discourse.SiteSettings.rating_tags.split('|').indexOf(t) !== -1;
                   }).length > 0,
      typeEnabled = type === 'rating';

  return catEnabled || tagEnabled || typeEnabled;
};

export { ratingEnabled };
