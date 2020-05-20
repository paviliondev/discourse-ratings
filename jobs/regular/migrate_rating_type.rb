# frozen_string_literal: true

module Jobs
  class MigrateRatingType < ::Jobs::Base
    def execute(args)
      DiscourseRatings::Rating.migrate_type(args)
    end
  end
end
