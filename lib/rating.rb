class DiscourseRatings::Rating
  include ActiveModel::SerializerSupport
  
  attr_accessor :type, :value
  
  def initialize(attrs)
    @type = attrs[:type].to_s
    @value = attrs[:value].to_i
  end
  
  def self.build_list(raw_ratings)
    if raw_ratings.present?
      raw_ratings.map do |rating|
        self.new(rating.with_indifferent_access)
      end
    else
      []
    end
  end
  
  def self.serialize(ratings)
    ActiveModel::ArraySerializer.new(ratings,
      each_serializer: DiscourseRatings::RatingSerializer
    )
  end
end