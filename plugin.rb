# name: discourse-ratings
# about: A Discourse plugin that lets you use topics to rate things
# version: 0.2
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-ratings

enabled_site_setting :rating_enabled

register_asset 'stylesheets/common/ratings.scss'
register_asset 'stylesheets/mobile/ratings.scss', :mobile

if respond_to?(:register_svg_icon)
  register_svg_icon "info"
  register_svg_icon "save"
end

add_admin_route 'admin.ratings.type.settings_page', 'rating-types'

after_initialize do
  %w[
    ../lib/engine.rb
    ../lib/rating.rb
    ../lib/rating_type.rb
    ../app/serializers/rating.rb
    ../app/serializers/rating_type.rb
    ../app/controllers/rating.rb
    ../app/controllers/rating_type.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  
  ###### Site ######
  
  add_to_class(:site, :rating_types) do 
    DiscourseRatings::RatingType.all
  end
  
  add_to_serializer(:site, :rating_types) do
    ActiveModel::ArraySerializer.new(object.rating_types,
      each_serializer: DiscourseRatings::RatingTypeSerializer
    )
  end
  
  
  ###### Category ######
  
  register_category_custom_field_type('rating_enabled', :boolean)

  add_to_class(:category, :rating_types) do
    if custom_fields["rating_types"].present?
      custom_fields["rating_types"].split('|')
    else
      []
    end
  end
  
  if Site.respond_to? :preloaded_category_custom_fields
    Site.preloaded_category_custom_fields << 'rating_enabled' 
    Site.preloaded_category_custom_fields << 'rating_types'
  end

  add_to_serializer(:basic_category, :rating_enabled) do
    object.custom_fields["rating_enabled"]
  end
  
  add_to_serializer(:basic_category, :rating_types) { object.rating_types }
  
  
  ###### Post ######
  
  add_permitted_post_create_param('ratings')
  register_post_custom_field_type('ratings', :json)
  
  on(:post_created) do |post, opts, user|
    if opts[:ratings].present?
      begin
        data = JSON.parse(opts[:ratings])
      rescue JSON::ParserError
        data = []
      end
            
      if data.any?
        post.update_ratings(DiscourseRatings::Rating.build_list(data))
      end
    end
  end

  on(:post_destroyed) do |post, opts, user|
    if (ratings = post.ratings).present?
      post.update_ratings(ratings, weight: 0)
    end
  end

  on(:post_recovered) do |post, opts, user|
    if (ratings = post.ratings).present?
      post.update_ratings(ratings)
    end
  end
  
  add_to_class(:post, :ratings) do
    DiscourseRatings::Rating.build_list(custom_fields["ratings"])
  end
  
  add_to_class(:post, :update_ratings) do |ratings, weight: 1|
    save_ratings(ratings, weight)
    update_topic_ratings
    push_ratings_to_clients
  end
  
  add_to_class(:post, :save_ratings) do |ratings, weight|
    data = {}
    
    ratings.each do |rating|
      data[:type] = rating.type
      data[:value] = rating.value
      data[:weight] = weight
    end
    
    custom_fields['ratings'] = data
    save_custom_fields(true)
  end
  
  add_to_class(:post, :update_topic_ratings) do
    types = topic.category.rating_types
    ratings = topic.posts.map { |p| p.ratings }.flatten
    
    return if types.blank? || ratings.blank?
    
    ratings = []
    
    types.each do |type|
      type_ratings = ratings.select do |rating|
        (rating[:weight].to_i === 1) &&
        (rating[:type] == type.to_s)
      end
      
      sum = type_ratings.map { |rating| rating[:value].to_i }.inject(:+)
      count = ratings.length
      average = (sum / count).to_f
      
      ratings.push(
        type: type,
        count: count,
        value: average
      )
    end

    topic.custom_fields['ratings'] = ratings
    topic.save_custom_fields(true)
  end
  
  add_to_class(:post, :push_ratings_to_clients) do
    publish_change_to_clients!("ratings", topic_ratings: topic.ratings)
  end
  
  add_to_serializer(:post, :ratings) do
    DiscourseRatings::Rating.serialize(object.ratings) 
  end
  
  
  ###### Topic ######
  
  register_topic_custom_field_type('ratings', :json)
  
  add_to_class(:topic, :ratings) do
    DiscourseRatings::Rating.build_list(custom_fields["ratings"])
  end
  
  add_to_class(:topic, :rating_enabled?) do
    !(tags & SiteSetting.rating_tags.split('|')).empty? ||
    (category && category.custom_fields["rating_enabled"])
  end
  
  add_to_serializer(:topic_view, :ratings) do
    DiscourseRatings::Rating.serialize(object.topic.ratings)
  end
    
  add_to_serializer(:topic_view, :rating_enabled) do
    object.topic.rating_enabled?
  end

  add_to_serializer(:topic_view, :has_ratings) do
    object.ratings.present?
  end
  
  add_to_serializer(:topic_view, :user_rating_types) do
    return {} if !scope.current_user || !rating_enabled
    user_ratings = object.posts.select do |post|
      post.user_id === scope.current_user.id &&
      post.ratings.present?
    end.map { |post| post.ratings.map(&:type) }
  end
  
  if TopicList.respond_to? :preloaded_custom_fields
    TopicList.preloaded_custom_fields << "ratings" 
  end
  
  add_to_serializer(:topic_list_item, :ratings) do
    DiscourseRatings::Rating.serialize(object.ratings)
  end

  add_to_serializer(:topic_list_item, :has_ratings) do
    object.ratings.present?
  end
end
