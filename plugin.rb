# name: discourse-ratings
# about: A Discourse plugin that lets you use topics to rate things
# version: 0.2
# authors: Angus McLeod
# url: https://github.com/angusmcleod/discourse-ratings

enabled_site_setting :rating_enabled

register_asset 'stylesheets/common/ratings.scss'
register_asset 'stylesheets/mobile/ratings.scss', :mobile

register_svg_icon "info" if respond_to?(:register_svg_icon)

Discourse.top_menu_items.push(:ratings)
Discourse.anonymous_top_menu_items.push(:ratings)
Discourse.filters.push(:ratings)
Discourse.anonymous_filters.push(:ratings)

after_initialize do
  add_admin_route 'ratings.rating_types.settings_page', 'rating-types'

  register_category_custom_field_type('rating_enabled', :boolean)
  register_topic_custom_field_type('ratings', :json)
  register_post_custom_field_type('ratings', :json)
  register_category_custom_field_type('rating_types', :json)

  module ::DiscourseRatings
    class Engine < ::Rails::Engine
      engine_name "discourse_ratings"
      isolate_namespace DiscourseRatings
    end
  end

  DiscourseRatings::Engine.routes.draw do
    post "/rate" => "rating#rate"
    post "/remove" => "rating#remove"

    post "/add_type" => "rating_types#add", constraints: StaffConstraint.new 
    put "/update_type" => "rating_types#update", constraints: StaffConstraint.new
    get "/list_types" => "rating_types#list", constraints: StaffConstraint.new
    delete "/delete_type" => "rating_types#destroy", constraints: StaffConstraint.new
  end

  Discourse::Application.routes.append do
    get '/admin/plugins/rating-types' => 'admin/plugins#index', constraints: StaffConstraint.new
    mount ::DiscourseRatings::Engine, at: "rating"
  end

  load File.expand_path('../controllers/rating.rb', __FILE__)
  load File.expand_path('../controllers/rating_types.rb', __FILE__)
  load File.expand_path('../serializers/rating_list.rb', __FILE__)
  load File.expand_path('../lib/ratings_helper.rb', __FILE__)

  TopicView.add_post_custom_fields_whitelister do |user|
    ['ratings']
  end

  TopicList.preloaded_custom_fields << "average_rating" if TopicList.respond_to? :preloaded_custom_fields
  TopicList.preloaded_custom_fields << "rating_count" if TopicList.respond_to? :preloaded_custom_fields
  TopicList.preloaded_custom_fields << "ratings" if TopicList.respond_to? :preloaded_custom_fields
  add_permitted_post_create_param('ratings', :hash)
  add_permitted_post_create_param('rating_target_id')

  DiscourseEvent.on(:post_created) do |post, opts, user|
    if opts[:ratings]
      ratingsParams = opts[:ratings]
      ratings = []
      ratingsParams.each do |_, rating|
        ratings << {rating_type_id: rating[:id], rating: rating[:value], rating_weight: 1 }
      end
      post.custom_fields['ratings'] = ratings
      post.save_custom_fields(true)
      RatingsHelper.handle_rating_update(post)
    end

    if opts[:rating_target_id]
      topic = Topic.find(post.topic_id)
      topic.custom_fields['rating_target_id'] = opts[:rating_target_id]
      topic.save_custom_fields(true)
    end
  end

  DiscourseEvent.on(:post_destroyed) do |post, opts, user|
    if post.custom_fields['rating']
      post.custom_fields["rating_weight"] = 0
      post.save_custom_fields(true)
      RatingsHelper.handle_rating_update(post)
    end
  end

  DiscourseEvent.on(:post_recovered) do |post, _opts, user|
    if post.custom_fields['rating']
      post.custom_fields["rating_weight"] = 1
      post.save_custom_fields(true)
      RatingsHelper.handle_rating_update(post)
    end
  end

  PostRevisor.track_topic_field(:rating_target_id)

  PostRevisor.class_eval do
    track_topic_field(:rating_target_id) do |tc, rating_target_id|
      tc.record_change('rating_target_id', tc.topic.custom_fields['rating_target_id'], rating_target_id)
      tc.topic.custom_fields['rating_target_id'] = rating_target_id
    end
  end

  require 'topic'
  class ::Topic
    def ratings
    self.custom_fields['ratings']
    end

    def average_rating
      if average = self.custom_fields["average_rating"]
        average.is_a?(Array) ? average[0].to_f : average.to_f
      end
    end

    def rating_enabled?
      has_rating_tag = !(tags & SiteSetting.rating_tags.split('|')).empty?
      is_rating_category = self.category && self.category.custom_fields["rating_enabled"]
      is_rating_topic = self.subtype == 'rating'
      has_rating_tag || is_rating_category || is_rating_topic
    end

    def rating_count
      rating_enabled? && self.ratings ? self.ratings.length : 0 
    end

    def rating_target_id
      self.custom_fields["rating_target_id"]
    end
  end

  require 'topic_view_serializer'
  class ::TopicViewSerializer
    attributes :average_rating, :rating_enabled, :rating_count, :can_rate, :rating_target_id, :has_ratings, :ratings

    def ratings
      object.topic.ratings
    end

    def average_rating
      object.topic.average_rating
    end

    def include_average_rating?
      SiteSetting.rating_topic_average_enabled && has_ratings
    end

    def rating_enabled
      object.topic.rating_enabled?
    end

    def rating_count
      object.topic.rating_count
    end

    def include_rating_count?
      has_ratings
    end

    def has_ratings
      object.topic.rating_count > 0
    end

    def can_rate
      scope.current_user && rating_enabled && !RatingsHelper.has_rated?(object, scope.current_user.id)
    end

    def rating_target_id
      object.topic.rating_target_id
    end
  end

  require 'topic_list_item_serializer'
  class ::TopicListItemSerializer
    attributes :average_rating, :rating_count, :show_average, :has_ratings, :ratings

    def average_rating
      object.average_rating
    end

    def ratings
      object.ratings
    end

    def include_average_rating?
      SiteSetting.rating_topic_list_average_enabled && has_ratings
    end

    def rating_count
      object.rating_count
    end

    def include_rating_count?
      has_ratings
    end

    def has_ratings
      object.rating_count > 0
    end

    def show_average
      object.rating_enabled?
    end
  end

  Site.preloaded_category_custom_fields << 'rating_enabled' if Site.respond_to? :preloaded_category_custom_fields
  Site.preloaded_category_custom_fields << 'rating_types' if Site.respond_to? :preloaded_category_custom_fields

  add_to_serializer(:basic_category, :rating_enabled) { object.custom_fields["rating_enabled"] }
  add_to_serializer(:basic_category, :rating_types) { JSON.parse(object.custom_fields["rating_types"] || {}) }
  add_to_serializer(:site, :rating_types) { PluginStoreRow.where(plugin_name: 'rating_type') }
  add_to_serializer(:post, :ratings) { post_custom_fields["ratings"] }

  require_dependency 'topic_query'
  class ::TopicQuery
    def list_ratings
      create_list(:ratings, ascending: 'true') do |topics|
        topics.where(subtype: 'rating')
      end
    end

    def list_top_ratings
      create_list(:top_ratings, unordered: true) do |topics|
        topics.where(subtype: 'rating')
          .joins("left join topic_custom_fields tfv ON tfv.topic_id = topics.id AND tfv.name = 'average_rating'")
          .order("coalesce(tfv.value,'0')::float desc, topics.bumped_at desc")
      end
    end
  end
end
