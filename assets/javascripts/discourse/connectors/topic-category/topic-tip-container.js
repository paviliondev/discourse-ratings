export default {
  shouldRender(_, ctx) {
    return (
      ctx.siteSettings.rating_enabled && ctx.siteSettings.rating_show_topic_tip
    );
  },
};
