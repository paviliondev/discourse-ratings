export default {
  setupComponent(args) {
    const category = args.category;
    if (!category.custom_fields) {
      category.custom_fields = {};
    }
  }
};
