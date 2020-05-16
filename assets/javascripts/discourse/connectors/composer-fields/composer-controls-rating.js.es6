export default {
  shouldRender(attrs) {
    return attrs.model.ratingEnabled;
  },

  actions: {
    updateRating(rating){
      const ratings = (this.get('model.ratings') || []);
      const index = ratings.findIndex(r => r.type === rating.type);
      
      if (index === -1) {
        ratings.push({
          type: rating.type,
          value: rating.value
        });
      } else {
        ratings[index].value = value;
      }
      
      this.set('model.ratings', ratings);
    }
  }
}