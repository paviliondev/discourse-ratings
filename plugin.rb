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

add_admin_route "admin.ratings.settings_page", "ratings"

after_initialize do
  %w[
    ../lib/ratings/engine.rb
    ../lib/ratings/rating.rb
    ../lib/ratings/rating_type.rb
    ../lib/ratings/object.rb
    ../config/routes.rb
    ../jobs/regular/migrate_rating_type.rb
    ../app/serializers/ratings/object.rb
    ../app/serializers/ratings/rating.rb
    ../app/serializers/ratings/rating_type.rb
    ../app/serializers/ratings/site.rb
    ../app/controllers/ratings/object.rb
    ../app/controllers/ratings/rating.rb
    ../app/controllers/ratings/rating_type.rb
    ../extensions/post_revisor.rb
    ../extensions/posts_controller.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  ###### Site ######
  
  add_to_class(:site, :rating_types) do 
    DiscourseRatings::RatingType.all
  end
  
  add_to_serializer(:site, :ratings) do
    DiscourseRatings::SiteSerializer.new(object, root: false)
  end
  
  ###### Category && Tag ######
  
  add_to_class(:category, :rating_types) do
    DiscourseRatings::Object.get('category', full_slug("/"))
  end
  
  add_to_class(:tag, :rating_types) do
    DiscourseRatings::Object.get('tag', name)
  end

  ###### Post ######
  
  add_permitted_post_create_param("ratings")
  
  on(:post_created) do |post, opts, user|
    if opts[:ratings].present?
      begin
        ratings = JSON.parse(opts[:ratings])
      rescue JSON::ParserError
        ratings = []
      end
      
      topic = post.topic
      user_can_rate = topic.user_can_rate(user)
      
      ratings = DiscourseRatings::Rating.build_list(ratings)
        .select { |r| user_can_rate.include?(r.type) }
                  
      if ratings.any?
        post.update_ratings(ratings)
      end
    end
  end
  
  ### These monkey patches are necessary as there is currently
  ### no way to add post attributes on update
   
  class ::PostRevisor
    cattr_accessor :ratings
    prepend PostRevisorRatingsExtension
  end

  ::PostsController.prepend PostsControllerRatingsExtension
  
  on(:post_edited) do |post, topic_changed, revisor|
    if revisor.ratings.present?
      topic = post.topic
      user = post.user
      user_has_rated = topic.user_has_rated(user)
      user_can_rate = topic.user_can_rate(user)

      ratings = DiscourseRatings::Rating.build_list(revisor.ratings)
        .select do |r|
          user_has_rated.include?(r.type) ||
          user_can_rate.include?(r.type)
        end
      
      post.update_ratings(ratings)
      revisor.ratings = nil
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
    DiscourseRatings::Rating.build_model_list(custom_fields, topic.rating_types)
  end
  
  add_to_class(:post, :update_ratings) do |ratings, weight: 1|
    Post.transaction do
      save_ratings(ratings, weight)
      update_topic_ratings
    end
    
    push_ratings_to_clients
  end
  
  add_to_class(:post, :save_ratings) do |ratings, weight|
    ratings.each do |rating|
      custom_fields["#{DiscourseRatings::Rating::KEY}_#{rating.type}"] = {
        value: rating.value,
        weight: weight
      }.to_json
    end
    save_custom_fields(true)
  end
  
  add_to_class(:post, :update_topic_ratings) do
    types = topic.rating_types
    post_ratings = topic.reload.posts.map { |p| p.ratings }.flatten
        
    return if types.blank? || post_ratings.blank?
    
    topic_ratings = []
    
    types.each do |type|
      type_ratings = post_ratings.select do |r|
        (r.weight === 1) && (r.type === type.to_s)
      end
                  
      if type_ratings.any?    
        sum = type_ratings.map { |r| r.value }.inject(:+)
        count = type_ratings.length
        average = (sum / count).to_f
        
        topic.custom_fields["#{DiscourseRatings::Rating::KEY}_#{type}"] = {
          value: average,
          count: count
        }.to_json
      end
    end

    topic.save_custom_fields(true)
  end
  
  add_to_class(:post, :push_ratings_to_clients) do
    publish_change_to_clients!("ratings",
      ratings: topic.ratings.as_json,
      user_can_rate: topic.user_can_rate(user)
    )
  end
  
  add_to_serializer(:post, :ratings) do
    DiscourseRatings::Rating.serialize(object.ratings) 
  end
  
  ###### Topic ######
      
  add_to_class(:topic, :ratings) do
    DiscourseRatings::Rating.build_model_list(custom_fields, rating_types)
  end
  
  add_to_class(:topic, :rating_types) do
    types = []
    types.push(category.rating_types) if category.present?
    types.push(tags.map { |tag| tag.rating_types }) if tags.present?
    types.flatten
  end
  
  add_to_class(:topic, :rating_enabled?) do
    rating_types.any?
  end
  
  add_to_class(:topic, :user_can_rate) do |user|
    rating_types.select do |type|
      user_has_rated(user).exclude?(type)
    end  
  end
  
  add_to_class(:topic, :user_has_rated) do |user|
    posts.select do |post|
      post.user_id === user.id && post.ratings.present?
    end.map do |post|
      post.ratings.map(&:type)
    end.flatten
  end
  
  add_to_serializer(:topic_view, :ratings) do
    DiscourseRatings::Rating.serialize(object.topic.ratings)
  end

  add_to_serializer(:topic_view, :show_ratings) do
    object.topic.rating_enabled?
  end
  
  add_to_serializer(:topic_view, :user_can_rate) do
    object.topic.user_can_rate(scope.current_user)
  end
  
  add_to_serializer(:topic_view, :include_user_can_rate?) do
    scope.current_user && object.topic.rating_enabled?
  end
  
  if TopicList.respond_to? :preloaded_custom_fields
    DiscourseRatings::RatingType.preload_custom_fields
  end
  
  add_to_serializer(:topic_list_item, :ratings) do
    DiscourseRatings::Rating.serialize(object.ratings)
  end

  add_to_serializer(:topic_list_item, :has_ratings) do
    object.ratings.present?
  end
end
