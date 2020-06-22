class DiscourseRatings::RatingSerializer < ::ApplicationSerializer
  attributes :type, :type_name, :value, :count
end