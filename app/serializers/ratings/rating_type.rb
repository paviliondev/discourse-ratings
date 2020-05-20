class DiscourseRatings::RatingTypeSerializer < ::ApplicationSerializer
  attributes :type, :name
  
  def type
    object[:key].split(DiscourseRatings::RatingType::KEY_PREFIX).last
  end
  
  def name
    object[:value]
  end
end