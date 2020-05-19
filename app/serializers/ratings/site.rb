class DiscourseRatings::SiteSerializer < ApplicationSerializer
  attributes :types, :categories, :tags
  
  def types
    ActiveModel::ArraySerializer.new(object.rating_types, each_serializer: DiscourseRatings::RatingTypeSerializer)
  end
  
  def categories
    create_object(DiscourseRatings::Object.list('category'))
  end
  
  def tags
    create_object(DiscourseRatings::Object.list('tag'))
  end
  
  private
  
  def create_object(list)
    result = {}
    list.each do |obj|
      result[obj.name] = obj.types if obj.types.any?
    end
    result
  end
end