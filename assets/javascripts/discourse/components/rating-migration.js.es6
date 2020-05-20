import discourseComputed from "discourse-common/utils/decorators";
import RatingType from '../models/rating-type';
import Component from "@ember/component";

const noneType = 'none';

export default Component.extend({
  classNames: "admin-ratings-migrate",
  
  @discourseComputed('categoryId', 'toType', 'fromType')
  migrateDisabled(categoryId, toType, fromType) {
    return [categoryId, toType, fromType].any(i => !i) ||
      (toType !== noneType && fromType !== noneType);
  },
  
  @discourseComputed('ratingTypes.[]', 'toType', 'fromType')
  migrateTypes(ratingTypes, toType, fromType) {
    let types = ratingTypes || [];
    if (!types.any(t => t.type === noneType)) {
      types.push({
        type: noneType,
        name: I18n.t('admin.ratings.type.none_type')
      });
    }
    return types;
  },
  
  actions: {
    migrate() {
      let data = {
        category_id: this.categoryId,
        current_type: this.fromType,
        new_type: this.toType,
      }
      
      this.set('startingMigration', true);
      
      RatingType.migrate(data).then(result => {
        if (result.success) {
          this.set('migrationMessage', 'admin.ratings.migrate.started');
        } else {
          this.set('migrationMessage', 'admin.ratings.error.migration_failed_to_start');
        }
      }).finally(() => this.set('startingMigration', false));
    }
  }
});