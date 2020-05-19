class DiscourseRatings::Rating
  include ActiveModel::SerializerSupport
  
  attr_accessor :type, :value, :weight, :count
  
  def initialize(attrs)
    @type = attrs[:type].to_s
    @value = attrs[:value].to_f
    @weight = attrs[:weight].to_i if attrs[:weight] != nil
    @count = attrs[:count].to_i if attrs[:count] != nil
  end
  
  def self.build_list(raw)
    if raw.present?
      (raw.is_a?(Array) ? raw : [raw]).map do |rating|
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