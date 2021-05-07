import discourseComputed from "discourse-common/utils/decorators";
import Rating from "../models/rating";
import Component from "@ember/component";

const noneType = "none";

export default Component.extend({
  classNames: ["rating-action-controls"],

  @discourseComputed("categoryId", "toType", "fromType")
  migrateDisabled(categoryId, toType, fromType) {
    return (
      [categoryId, toType, fromType].any((i) => !i) ||
      (toType !== noneType && fromType !== noneType)
    );
  },

  actions: {
    migrate() {
      let data = {
        category_id: this.categoryId,
        type: this.fromType,
        new_type: this.toType,
      };

      this.set("startingMigration", true);

      Rating.migrate(data)
        .then((result) => {
          if (result.success) {
            this.set("migrationMessage", "admin.ratings.migrate.started");
          } else {
            this.set(
              "migrationMessage",
              "admin.ratings.error.migration_failed_to_start"
            );
          }
        })
        .finally(() => this.set("startingMigration", false));
    },
  },
});
