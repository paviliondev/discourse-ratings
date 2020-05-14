module RatingsHelper
  class << self
    def handle_rating_update(post)
      count = update_rating_count(post.topic)
      average = calculate_topic_average(post.topic)
      push_ratings_to_clients(post.topic, average, count, post.id)
    end

    def aggregate_rating_array(topic)
      post_rating_arrays = topic.posts.map{ |p| p.custom_fields['ratings'] }
      post_rating_arrays.flatten
    end

    def filter_by_type(rating_array, type)
      rating_array.select { |rating| rating ? rating['rating_type_id'] == type.to_s : false }
    end

    def average_rating(filtered_array)
      filtered_array.map {|rating| rating['rating'].to_i}.inject(:+) / filtered_array.length
    end

    def rating_count(filtered_array)
      filtered_array.length
    end

    def update_rating_count(topic)
      count = {}
      rating_types = topic.category.custom_fields['rating_types']
      rating_types = JSON.parse rating_types
      return if !rating_types

      rating_array = aggregate_rating_array(topic)
      if rating_array
        rating_types.each do |type|
          type_ratings = filter_by_type(rating_array, type)
          type_count = rating_count(type_ratings)
          count[type] = type_count
        end
      end

      if topic.custom_fields['ratings'] 
        topic.custom_fields['ratings'].each do |rating|
          rating['rating_count'] = count[rating['rating_type_id']]
        end
      else
        ratings = []
        rating_types.each do |type|
          ratings << {rating_type_id: type, rating_count: count[type]}
        end

        topic.custom_fields['ratings'] = ratings
      end
      topic.save_custom_fields(true)

      count
    end

    def calculate_topic_average(topic)
      average = {}
      rating_types = topic.category.custom_fields['rating_types']
      rating_types = JSON.parse rating_types
      return if !rating_types

      rating_array = aggregate_rating_array(topic)
      if rating_array
        rating_types.each do |type|
          type_ratings = filter_by_type(rating_array, type)
          type_average = average_rating(type_ratings)
          average[type] = type_average
        end
      end
    if topic.custom_fields['ratings'] 
      topic.custom_fields['ratings'].each do |rating|
        rating['average_rating'] = average[rating['rating_type_id']]
      end
    else
      topic.custom_fields['ratings'] = ratings =  []
      rating_types.each do |type|
        ratings << {rating_type_id: type, average_rating: count[type]}
      end
    end
  topic.save_custom_fields(true)

    average
    end

    def push_ratings_to_clients(topic, average, count, updatedId = '')
      channel = "/topic/#{topic.id}"
      msg = {
        updated_at: Time.now,
        average_rating: average,
        rating_count: count,
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

    ## This should be replaced with a :rated? property in TopicUser - but how to do this in a plugin?
    def has_rated?(topic, user_id)
      @user_posts = topic.posts.select { |post| post.user_id === user_id }
      PostCustomField.exists?(post_id: @user_posts.map(&:id), name: "rating")
    end
  end
end
