# frozen_string_literal: true

module Jobs
  class MigrateRatings < ::Jobs::Base
    def execute(args)
      DiscourseRatings::Rating.migrate(type: args[:type])
    end
  end
end