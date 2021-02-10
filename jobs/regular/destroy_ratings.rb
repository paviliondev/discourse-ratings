# frozen_string_literal: true

module Jobs
  class DestroyRatings < ::Jobs::Base
    def execute(args)
      DiscourseRatings::Rating.destroy(type: args[:type], category_id: args[:category_id])
    end
  end
end
