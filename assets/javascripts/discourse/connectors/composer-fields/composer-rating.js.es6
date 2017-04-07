export default {
  setupComponent(args, component) {
    component.set('showRating', args.model.get('showRating') && args.model.get('ratingPluginDisplay'))
    Ember.addObserver(args.model, 'showRating', this, function(model, property) {
      if (component._state == 'destroying') { return }

      component.set('showRating', args.model.get('showRating') && args.model.get('ratingPluginDisplay'))
    })
  }
}
