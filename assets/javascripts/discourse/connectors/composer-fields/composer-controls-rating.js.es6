export default {
  setupComponent(attrs, component) {
    if(!component.get('model.ratingEnabled')) {
      return;
    }
    const ratingTypesEnabled = component.get('model.category.rating_types');
    const siteRatingTypes = component.get('site.rating_types');
    this.set('model.ratings', []);
    // const ratingsArray = siteRatingTypes.forEach((type) => {
    //   if(ratingTypesEnabled.includes(type.id)) {
    //     // component.get("model.ratings").push(type);
    //   } 
    // });
  },
  actions: {
    updateRating(ratingType, rating){
      const ratings = this.get('model.ratings') || [];
      let ratingIndex = ratings.findIndex(rating => rating.id === ratingType);
      if(ratingIndex === -1) {
        ratings.push({id: ratingType, value: rating});
      } else {
        ratings[ratingIndex]['value'] = rating;
      }
      this.set('model.ratings', ratings);
    }
  }
}