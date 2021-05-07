export default {
  shouldRender(_, ctx) {
    return ctx.siteSettings.rating_enabled;
  },
};
