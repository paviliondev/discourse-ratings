# frozen_string_literal: true

module Jobs
  class DestoryRatingType < ::Jobs::Base
    def execute(args)
      type = args[:type]
      
      ActiveRecord::Base.transaction do
        DiscourseRatings::Rating.destroy_type(type)
        DiscourseRatings::Object.remove_type("category", type)
        DiscourseRatings::Object.remove_type("tag", type)
        DiscourseRatings::RatingType.destroy(type)
      end
    end
  end
end
