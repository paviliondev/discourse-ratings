import discourseComputed from "discourse-common/utils/decorators";
import RatingObject from '../models/rating-object';
import Component from "@ember/component";
import { notEmpty } from "@ember/object/computed";
import I18n from "I18n";

export default Component.extend({
  classNameBindings: [':object-types', 'objectType'],
  hasObjects: notEmpty('objects'),
  
  @discourseComputed('objectType')
  title(objectType) {
    return I18n.t(`admin.ratings.${objectType}.title`);
  },
  
  @discourseComputed('objectType')
  nameLabel(objectType) {
    return I18n.t(`admin.ratings.${objectType}.name`);
  },
  
  @discourseComputed('objectType')
  noneLabel(objectType) {
    return I18n.t(`admin.ratings.${objectType}.none`);
  },
  
  @discourseComputed('objectType')
  objectList(objectType) {
    const site = this.site;
        
    if (objectType === 'category') {
      return site.categories.map(c => {
        return {
          id: c.fullSlug,
          name: c.name
        }
      });
    }
    if (objectType === 'tag' && site.top_tags) {
      return site.top_tags.map(t => {
        return {
          id: t,
          name: t
        }
      });
    }
  },
  
  actions: {
    newObject() {
      this.get('objects').pushObject({
        name: '',
        types: [],
        isNew: true
      })
    },

    updateObject(obj) {
      let data = {
        name: obj.name,
        types: obj.types
      }
      this.set('loading', true);
      RatingObject.update(this.objectType, data).then((result) => {
        if (result.success) {
          this.refresh();
        } else {
          this.set('loading', false)
        }
      });
    },
    
    destroyObject(obj) {
      if (obj.isNew) {
        this.get('objects').removeObject(obj)
      } else {
        let data = {
          name: obj.name
        }
        
        this.set('loading', true);
        RatingObject.destroy(this.objectType, data).then((result) => {
          if (result.success) {
            this.refresh();
          } else {
            this.set('loading', false);
          }
        });
      }
    }
  }
})