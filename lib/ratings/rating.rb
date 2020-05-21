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
  
  def self.build_and_set(model, ratings)
    ratings = build_list(ratings)
    set_custom_fields(model, ratings)
  end
  
  def self.set_custom_fields(model, ratings)
    [*ratings].each do |rating|
      data = {
        value: rating.value
      }
      data[:weight] = rating.weight if rating.weight.present?
      data[:count] = rating.count if rating.count.present?  
      model.custom_fields[field_name(rating.type)] = data.to_json
    end
  end
  
  def self.destroy(args)    
    if args.keys.exclude?(:type)
      return nil
    end
    
    name = field_name(args[:type])
    
    topics = Topic.all
    
    if args[:category_id].present?
      topics = topics.where(category_id: args[:category_id].to_i)
    end
    
    topic_ids = topics.pluck(:id)
            
    if topic_ids.any?
      post_ids = Post.where(topic_id: topic_ids).pluck(:id)
      
      ActiveRecord::Base.transaction do
        TopicCustomField.where(
          topic_id: topic_ids,
          name: name
        ).destroy_all
        PostCustomField.where(
          post_id: post_ids,
          name: name
        ).destroy_all
      end
    end
  end
    
  def self.migrate(args, opts={})
    if args.keys.exclude?(:type) ||
       args.keys.exclude?(:new_type) ||
       args.values.exclude?(DiscourseRatings::RatingType::NONE)
      return nil
    end
    
    topics = Topic.all
    
    if args[:category_id].present?
      topics = topics.where(category_id: args[:category_id].to_i)
    end
    
    current_name = field_name(args[:type])
    new_name = field_name(args[:new_type])
    
    topics = topics.where("id in (
      SELECT topic_id FROM topic_custom_fields
      WHERE name = '#{current_name}'
    )")
    
    unless opts[:ignore_duplicates]
      topics = topics.where("id not in (
        SELECT topic_id FROM topic_custom_fields
        WHERE name = '#{new_name}'
      )")
    end
    
    topic_ids = topics.pluck(:id)
    
    if topic_ids.any?
      post_ids = Post.where(topic_id: topic_ids).pluck(:id)
      
      ActiveRecord::Base.transaction do
        TopicCustomField.where(
          topic_id: topic_ids,
          name: current_name
        ).update_all(name: new_name)
        
        PostCustomField.where(
          post_id: post_ids,
          name: current_name
        ).update_all(name: new_name)
      end
    end
    
    preload_custom_fields
  end
  
  def self.build_model_list(custom_fields, types)
    build_list(
      types.reduce([]) do |result, type|
        data = custom_fields[field_name(type)]
        
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
  
  def self.preload_custom_fields    
    DiscourseRatings::RatingType.all.each do |row|
      type = DiscourseRatings::RatingType.type_from_key(row.key)
      TopicList.preloaded_custom_fields << field_name(type)
    end
    
    TopicList.preloaded_custom_fields << field_name(DiscourseRatings::RatingType::NONE)
  end
    
  def self.field_name(type)
    "#{KEY}_#{type.parameterize.underscore}"
  end
end