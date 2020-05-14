export default {
  setupComponent(attrs, component) {
    let ratingTypes = {};
    this.model.ratings.forEach(element => {
      let type = this.site.rating_types.find(elem => elem.id == element.rating_type_id);
          element.name = type ? type.value : "";
        });
    console.log(this.model.ratings, this.site.rating_types)
    // this.site.rating_types.forEach(type => {
    //   ratingTypes[type.id] = type.value;
    // });
    this.set('ratingTypes', ratingTypes);
  }
}