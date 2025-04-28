import Component from "@ember/component";
import { action } from "@ember/object";
import { classNames } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";
import Rating from "../models/rating";

const noneType = "none";

@classNames("rating-action-controls")
export default class RatingMigrate extends Component {
  @discourseComputed("categoryId", "toType", "fromType")
  migrateDisabled(categoryId, toType, fromType) {
    return (
      [categoryId, toType, fromType].any((i) => !i) ||
      (toType !== noneType && fromType !== noneType)
    );
  }

  @action
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
  }
}
