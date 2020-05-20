class DiscourseRatings::RatingTypeSerializer < ::ApplicationSerializer
  attributes :type, :name
  
  def type
    object[:key].split("type_").last
  end
  
  def name
    object[:value]
  end
end