class DiscourseRatings::RatingTypeSerializer < ::ApplicationSerializer
  attributes :slug, :name
  
  def slug
    object[:key].split("type_").last
  end
  
  def name
    object[:value]
  end
end