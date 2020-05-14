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

Discourse.top_menu_items.push(:ratings)
Discourse.anonymous_top_menu_items.push(:ratings)
Discourse.filters.push(:ratings)
Discourse.anonymous_filters.push(:ratings)

after_initialize do
  add_admin_route 'admin.ratings.type.settings_page', 'rating-types'
  
  register_category_custom_field_type('rating_enabled', :boolean)
  register_topic_custom_field_type('ratings', :json)
  register_post_custom_field_type('ratings', :json)
  
  %w[
    ../lib/engine.rb
    ../lib/rating_type.rb
    ../lib/ratings_helper.rb
    ../app/serializers/rating_list.rb
    ../app/serializers/rating_type.rb
    ../app/controllers/rating.rb
    ../app/controllers/rating_type.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  if Site.respond_to? :preloaded_category_custom_fields
    Site.preloaded_category_custom_fields << 'rating_enabled' 
    Site.preloaded_category_custom_fields << 'rating_types'
  end
  
  if TopicList.respond_to? :preloaded_custom_fields
    TopicList.preloaded_custom_fields << "ratings" 
  end

  TopicView.add_post_custom_fields_whitelister { |user| ['ratings'] }
  
  add_permitted_post_create_param('ratings')
  add_permitted_post_create_param('rating_target_id')
  
  add_to_class(:topic, :ratings) do
    if custom_fields["ratings"].present?
      custom_fields["ratings"].map do |rating|
        rating.with_indifferent_access
      end
    else
      []
    end
  end
  
  add_to_class(:topic, :average_rating) do
    if average = self.custom_fields["average_rating"]
      average.is_a?(Array) ? average[0].to_f : average.to_f
    end
  end
  
  add_to_class(:topic, :rating_enabled?) do
    has_rating_tag = !(tags & SiteSetting.rating_tags.split('|')).empty?
    is_rating_category = self.category && self.category.custom_fields["rating_enabled"]
    is_rating_topic = self.subtype == 'rating'
    has_rating_tag || is_rating_category || is_rating_topic
  end
  
  add_to_class(:topic, :rating_count) do
    rating_enabled? && self.ratings ? self.ratings.length : 0 
  end
  
  add_to_class(:topic, :rating_target_id) do
    self.custom_fields["rating_target_id"]
  end
  
  add_to_serializer(:topic_view, :rating_enabled) do
    object.topic.rating_enabled?
  end
  
  add_to_serializer(:topic_view, :ratings) do
    object.topic.ratings
  end
  
  add_to_serializer(:topic_view, :has_ratings) do
    object.topic.rating_count > 0
  end
  
  add_to_serializer(:topic_view, :can_rate) do
    scope.current_user &&
    rating_enabled &&
    !RatingsHelper.has_rated?(object, scope.current_user.id)
  end
  
  add_to_serializer(:topic_view, :rating_target_id) do
    object.topic.rating_target_id
  end
  
  add_to_serializer(:topic_list_item, :ratings) do
    object.ratings
  end
  
  add_to_serializer(:topic_list_item, :has_ratings) do
    object.rating_count > 0
  end
  
  add_to_serializer(:topic_list_item, :show_average) do
    object.rating_enabled?
  end

  on(:post_created) do |post, opts, user|
    if opts[:ratings].present?
      begin
        ratings = JSON.parse(opts[:ratings])
      rescue JSON::ParserError
        ratings = []
      end
      RatingsHelper.handle_rating_update(post, ratings)
    end

    if opts[:rating_target_id]
      topic = Topic.find(post.topic_id)
      topic.custom_fields['rating_target_id'] = opts[:rating_target_id]
      topic.save_custom_fields(true)
    end
  end

  on(:post_destroyed) do |post, opts, user|
    if (ratings = post.ratings).present?
      RatingsHelper.handle_rating_update(post, ratings, weight: 0)
    end
  end

  on(:post_recovered) do |post, _opts, user|
    if (ratings = post.ratings).present?
      RatingsHelper.handle_rating_update(post, ratings)
    end
  end

  PostRevisor.track_topic_field(:rating_target_id) do
    track_topic_field(:rating_target_id) do |tc, rating_target_id|
      tc.record_change('rating_target_id', tc.topic.custom_fields['rating_target_id'], rating_target_id)
      tc.topic.custom_fields['rating_target_id'] = rating_target_id
    end
  end
  
  add_to_class(:category, :rating_types) do
    if custom_fields["rating_types"].present?
      custom_fields["rating_types"].split('|')
    else
      []
    end
  end

  add_to_serializer(:basic_category, :rating_enabled) do
    object.custom_fields["rating_enabled"]
  end
  
  add_to_serializer(:basic_category, :rating_types) { object.rating_types }
  
  add_to_class(:site, :rating_types) do 
    DiscourseRatings::RatingType.all
  end
  
  add_to_serializer(:site, :rating_types) do
    ActiveModel::ArraySerializer.new(object.rating_types,
      each_serializer: DiscourseRatings::RatingTypeSerializer
    )
  end
  
  add_to_class(:post, :ratings) do
    if custom_fields["ratings"].present?
      custom_fields["ratings"].map do |rating|
        rating.with_indifferent_access
      end
    else
      []
    end
  end
  
  add_to_serializer(:post, :ratings) { post.ratings }
  
  add_to_class(:topic_query, :list_ratings) do
    create_list(:ratings, ascending: 'true') do |topics|
      topics.where(subtype: 'rating')
    end
  end
  
  add_to_class(:topic_query, :list_top_ratings) do
    create_list(:top_ratings, unordered: true) do |topics|
      topics.where(subtype: 'rating')
        .joins("left join topic_custom_fields tfv ON tfv.topic_id = topics.id AND tfv.name = 'average_rating'")
        .order("coalesce(tfv.value,'0')::float desc, topics.bumped_at desc")
    end
  end
end
