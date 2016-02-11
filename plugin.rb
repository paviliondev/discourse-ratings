# name: discourse-ratings
# about: A Discourse plugin that lets use topics to rate services or products
# version: 0.1
# authors: Angus McLeod

register_asset 'stylesheets/desktop-civil.scss', :desktop

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
      save_rating_to_post(post)
      add_rating_to_topic_average(post)
      render json: success_json
    end

    def save_rating_to_post(post)
      post.custom_fields["rating"] = params[:rating].to_i
      post.save!
    end

    def add_rating_to_topic_average(post)
      @topic_posts = Post.where(topic_id: post.topic_id)
      @all_ratings = PostCustomField.where(post_id: @topic_posts.map(&:id), name: "rating").pluck('value').map(&:to_i)
      average = @all_ratings.inject(:+).to_f / @all_ratings.length
      post.topic.custom_fields["average_rating"] = average
      post.topic.custom_fields["ratings"] = @all_ratings.length
      post.topic.save!
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
    mount ::DiscourseRatings::Engine, at: "service"
  end

  TopicView.add_post_custom_fields_whitelister do |user|
    ["rating"]
  end

  TopicList.preloaded_custom_fields << "average_rating" if TopicList.respond_to? :preloaded_custom_fields

  add_to_serializer(:post, :rating) {post_custom_fields["rating"]}
  add_to_serializer(:topic_view, :average_rating) {object.topic.custom_fields["average_rating"]}
  add_to_serializer(:topic_view, :ratings) {object.topic.custom_fields["ratings"]}
end
