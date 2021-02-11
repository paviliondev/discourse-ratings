# frozen_string_literal: true
class DiscourseRatings::RatingSerializer < ::ApplicationSerializer
  attributes :type, :type_name, :value, :count, :weight
end
