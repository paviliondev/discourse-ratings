# frozen_string_literal: true

module Jobs
  class MigrateRatings < ::Jobs::Base
    def execute(args)
      DiscourseRatings::Rating.migrate(
        category_id: args[:category_id],
        type: args[:type],
        new_type: args[:new_type],
      )
    end
  end
end
