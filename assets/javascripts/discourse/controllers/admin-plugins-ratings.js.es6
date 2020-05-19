import Controller from "@ember/controller";
import RatingType from '../models/rating-type';
import { notEmpty } from "@ember/object/computed";
import I18n from "I18n";

export default Controller.extend({
  hasTypes: notEmpty('ratingTypes'),
  
  actions: {
    newType() {
      this.get('ratingTypes').pushObject(
        RatingType.create({
          isNew: true,
          slug: '',
          name: ''
        })
      )
    },
    
    addType(typeObj) {
      let type = {
        slug: typeObj.slug,
        name: typeObj.name
      }
      
      this.set('loading', true);
      RatingType.add(type).then((result) => {
        if (result.success) {
          this.send('refresh');
        } else {
          type.set('hasError', true);
          this.set('loading', false)
        }
      });
    },
    
    updateType(typeObj) {
      let type = {
        slug: typeObj.slug,
        name: typeObj.name
      }
      
      this.set('loading', true);
      RatingType.update(type).then((result) => {
        if (result.success) {
          this.send('refresh');
        } else {
          typeObj.set('hasError', true);
          this.set('loading', false)
        }
      });
    },
    
    destroyType(typeObj) {
      if (typeObj.isNew) {
        this.get('ratingTypes').removeObject(typeObj)
      } else {
        bootbox.confirm(
          I18n.t("admin.ratings.type.confirm_destroy"),
          I18n.t("no_value"),
          I18n.t("yes_value"),
          result => {
            if (result) {
              let type = {
                slug: typeObj.slug
              }
              
              this.set('loading', true);
              RatingType.destroy(type).then((result) => {
                if (result.success) {
                  this.send('refresh');
                } else {
                  typeObj.set('hasError', true);
                  this.set('loading', false);
                }
              });
            }
          }
        );
      }
    }
  }
})