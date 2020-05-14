export default {
  shouldRender(attrs) {
    return attrs.model.ratingEnabled;
  },

  actions: {
    updateRating(type, value){
      const ratings = (this.get('model.ratings') || []);
      const index = ratings.findIndex(r => r.type === type);
      
      if (index === -1) {
        ratings.push({
          type,
          value
        });
      } else {
        ratings[index].value = value;
      }
      
      this.set('model.ratings', ratings);
    }
  }
}