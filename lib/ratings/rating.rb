class DiscourseRatings::Rating
  include ActiveModel::SerializerSupport
  
  KEY ||= "rating"
  
  attr_accessor :type, :value, :weight, :count
  
  def initialize(attrs)
    @type = attrs[:type].to_s
    @value = attrs[:value].to_f
    @weight = attrs[:weight].to_i if attrs[:weight] != nil
    @count = attrs[:count].to_i if attrs[:count] != nil
  end
  
  def self.build_model_list(custom_fields, types)
    types.push(DiscourseRatings::RatingType::NONE)
    
    build_list(
      types.reduce([]) do |result, type|
        data = custom_fields["#{KEY}_#{type}"]
        
        ## There should only be one rating type per instance
        data = data.first if data.is_a?(Array)
        
        if data.present?
          begin
            rating_data = JSON.parse(data)
          rescue JSON::ParserError
            rating_data = {}
          end
          
          result.push({ type: type }.merge(rating_data))
        end
        
        result
      end
    )
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