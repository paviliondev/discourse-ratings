export default {
  setupComponent(args, component) {
    const category = args.category;
    if (!category['custom_fields']) {
      category['custom_fields'] = {}
    }
    component.set('ratingTypes', this.site.rating_types);
    let ratingTypes = this.get('category.custom_fields.rating_types');
    this.set('selectedRatingTypes', JSON.parse(ratingTypes));

    this.addObserver('selectedRatingTypes', function(category){
      component.set('category.custom_fields.rating_types', JSON.stringify(this.selectedRatingTypes));
    });

  }
};
