class DiscourseRatings::RatingTypeSerializer < ::ApplicationSerializer
  attributes :type, :name
  
  def type
    DiscourseRatings::RatingType.type_from_key(object[:key])
  end
  
  def name
    object[:value]
  end
end