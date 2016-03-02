# name: discourse-ratings
# about: A Discourse plugin that lets you use topics to rate things
# version: 0.1
# authors: Angus McLeod

register_asset 'stylesheets/ratings-desktop.scss', :desktop

after_initialize do

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
      post.save!
      add_rating_to_topic_average(post)
    end

    def add_rating_to_topic_average(post)
      @topic_posts = Post.where(topic_id: post.topic_id)
      @all_ratings = PostCustomField.where(post_id: @topic_posts.map(&:id), name: "rating").pluck('value').map(&:to_i)
      average = @all_ratings.inject(:+).to_f / @all_ratings.length
      post.topic.custom_fields["average_rating"] = average
      post.topic.save!
      push_updated_ratings_to_clients!(post, average)
    end

    def push_updated_ratings_to_clients!(post, average)
      channel = "/topic/#{post.topic_id}"
      msg = {
        id: post.id,
        updated_at: Time.now,
        average: average,
        type: "revised"
      }
      MessageBus.publish(channel, msg, group_ids: post.topic.secure_group_ids)
      render json: success_json
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

  DiscourseRatings::Engine.routes.draw do
    post "/rate" => "rating#rate"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseRatings::Engine, at: "rating"
  end

  TopicView.add_post_custom_fields_whitelister do |user|
    ["rating"]
  end

  TopicList.preloaded_custom_fields << "average_rating" if TopicList.respond_to? :preloaded_custom_fields

  require 'topic_view_serializer'
  class ::TopicViewSerializer
    attributes :average_rating, :show_ratings, :can_rate

    def average_rating
      object.topic.custom_fields["average_rating"]
    end

    def show_ratings
      has_rating_tag = TopicCustomField.exists?(topic_id: object.topic.id, name: "tags", value: "rating")
      has_rating_tag || !!object.topic.category.custom_fields["rating_enabled"]
    end

    def can_rate
      user = object.topic_user
      return true if !user.respond_to?(:posted?)
      show_ratings && !user.posted?
    end

  end

  require 'topic_list_item_serializer'
  class ::TopicListItemSerializer
    attributes :average_rating, :show_average

    def average_rating
      object.custom_fields["average_rating"]
    end

    def show_average
      has_rating_tag = TopicCustomField.exists?(topic_id: object.id, name: "tags", value: "rating")
      is_rating_category = CategoryCustomField.where(category_id: object.category_id, name: "rating_enabled").pluck('value')
      has_rating_tag || is_rating_category.first == "true"
    end
  end

  ## Add the new fields to the serializers
  add_to_serializer(:basic_category, :rating_enabled) {object.custom_fields["rating_enabled"] == 'true'}
  add_to_serializer(:post, :rating) {post_custom_fields["rating"]}
end
