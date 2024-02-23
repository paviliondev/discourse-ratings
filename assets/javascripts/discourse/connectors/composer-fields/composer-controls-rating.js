import { set } from "@ember/object";

export default {
  actions: {
    updateRating(rating) {
      const ratings = this.get("model.ratings") || [];
      const index = ratings.findIndex((r) => r.type === rating.type);
      set(ratings[index], "value", rating.value);
      this.set("model.ratings", ratings);
    },
  },
};
