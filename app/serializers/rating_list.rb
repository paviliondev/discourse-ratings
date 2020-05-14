class DiscourseRatings::RatingListSerializer < ::ApplicationSerializer
  attributes :id, :title, :url, :average_rating, :category_id, :featured_link

  def average_rating
    object.custom_fields["average_rating"]
  end

  def url
    object.relative_url
  end
end
