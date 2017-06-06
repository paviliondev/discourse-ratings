# name: discourse-ratings
# about: A Discourse plugin that lets you use topics to rate things
# version: 0.2
# authors: Angus McLeod

register_asset 'stylesheets/ratings-desktop.scss'

after_initialize do

  Category.register_custom_field_type('rating_enabled', :boolean)

  module ::DiscourseRatings
    class Engine < ::Rails::Engine
      engine_name "discourse_ratings"
      isolate_namespace DiscourseRatings
    end
  end

  require_dependency "application_controller"
  class DiscourseRatings::RatingController < ::ApplicationController
    def rate
      post = Post.find(params[:id].to_i)
      post.custom_fields["rating"] = params[:rating].to_i
      post.custom_fields["rating_weight"] = 1
      post.save!

      average = RatingsHelper.calculate_topic_average(post.topic)
      RatingsHelper.push_ratings_to_clients(post.topic, average, post.id)
      render json: success_json
    end

    def weight
      post = Post.with_deleted.find(params[:id].to_i)
      post.custom_fields["rating_weight"] = params[:weight].to_i
      post.save!

      average = RatingsHelper.calculate_topic_average(post.topic)
      RatingsHelper.push_ratings_to_clients(post.topic, average, post.id)
      render json: success_json
    end

    def remove
      id = params[:id].to_i
      post = Post.find(id)
      PostCustomField.destroy_all(post_id: id, name:"rating")
      PostCustomField.destroy_all(post_id: id, name:"rating_weight")

      average = RatingsHelper.calculate_topic_average(post.topic)
      RatingsHelper.push_ratings_to_clients(post.topic, average, post.id)
      render json: success_json
    end
  end

  DiscourseRatings::Engine.routes.draw do
    post "/rate" => "rating#rate"
    post "/weight" => "rating#weight"
    post "/remove" => "rating#remove"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseRatings::Engine, at: "rating"
  end

  TopicView.add_post_custom_fields_whitelister do |user|
    ["rating", "rating_weight"]
  end

  TopicList.preloaded_custom_fields << "average_rating" if TopicList.respond_to? :preloaded_custom_fields

  module RatingsHelper
    class << self
      def calculate_topic_average(topic)
        @topic_posts = Post.with_deleted.where(topic_id: topic.id)
        @ratings = []
        @topic_posts.each do |tp|
          weight = tp.custom_fields["rating_weight"]
          if tp.custom_fields["rating"] && (weight.blank? || weight.to_i > 0)
            rating = tp.custom_fields["rating"].to_i
            @ratings.push(rating)
          end
        end
        average = @ratings.empty? ? nil : @ratings.inject(:+).to_f / @ratings.length
        average = average.round(1)
        topic.custom_fields["average_rating"] = average
        topic.save!
        return average
      end

      def push_ratings_to_clients(topic, average, updatedId='')
        channel = "/topic/#{topic.id}"
        msg = {
          updated_at: Time.now,
          average: average,
          post_id: updatedId,
          type: "revised"
        }
        MessageBus.publish(channel, msg, group_ids: topic.secure_group_ids)
      end

      ##def update_top_topics(post)
      ##  @category_topics = Topic.where(category_id: post.topic.category_id, tags: post.topic.tags[0])
      ##  @all_place_ratings = TopicCustomField.where(topic_id: @category_topics.map(&:id), name: "average_rating").pluck('value', 'topic_id').map(&:to_i)

        ## To do: Add a bayseian estimate of a weighted rating (WR) to WR = (v ÷ (v+m)) × R + (m ÷ (v+m)) × C
        ## R = average for the topic = (Rating); v = number of votes for the topic
        ## m = minimum votes required to be listed in the top list (currently 1)
        ## C = the mean vote for all topics
        ## See further http://bit.ly/1XLPS97 and http://bit.ly/1HJGW2g
      ##end
    end
  end

  DiscourseEvent.on(:post_created) do |post, opts, user|
    if opts[:rating]
      post.custom_fields['rating'] = opts[:rating]
      post.save!
      average = RatingsHelper.calculate_topic_average(post.topic)
      RatingsHelper.push_ratings_to_clients(post.topic, average, post.id)
    end
  end

  DiscourseEvent.on(:post_destroyed) do |post, opts, user|
    if post.custom_fields['rating']
      post.custom_fields["rating_weight"]
      post.save!
      average = RatingsHelper.calculate_topic_average(post.topic)
      RatingsHelper.push_ratings_to_clients(post.topic, average, post.id)
    end
  end

  PostRevisor.track_topic_field(:rating) do |tc, rating|
    puts "track_topic_field: #{tc.as_json}, #{rating}"
  end

  require 'topic_view_serializer'
  class ::TopicViewSerializer
    attributes :average_rating, :rating_enabled, :can_rate

    def average_rating
      object.topic.custom_fields["average_rating"].to_f
    end

    def rating_enabled
      topic = object.topic
      has_rating_tag = !(tags & SiteSetting.rating_tags.split('|')).empty?
      is_rating_category = topic.category && topic.category.custom_fields["rating_enabled"]
      is_rating_topic = topic.subtype == 'rating'
      average_rating > 0 && (has_rating_tag || is_rating_category || is_rating_topic)
    end

    def can_rate
      return false if !scope.current_user
      ## This should be replaced with a :rated? property in TopicUser - but how to do this in a plugin?
      @user_posts = object.posts.select{ |post| post.user_id === scope.current_user.id}
      rated = PostCustomField.exists?(post_id: @user_posts.map(&:id), name: "rating")
      rating_enabled && !rated
    end

  end

  require 'topic_list_item_serializer'
  class ::TopicListItemSerializer
    attributes :average_rating, :show_average

    def average_rating
      object.custom_fields["average_rating"]
    end

    def show_average
      return false if !average_rating
      has_rating_tag = !(tags & SiteSetting.rating_tags.split('|')).empty?
      is_rating_category = CategoryCustomField.where(category_id: object.category_id, name: "rating_enabled").pluck('value')
      has_rating_tag || is_rating_category.first == "true"
    end
  end

  ## Add the new fields to the serializers
  add_to_serializer(:basic_category, :rating_enabled) {object.custom_fields["rating_enabled"]}
  add_to_serializer(:post, :rating) {post_custom_fields["rating"]}
end
