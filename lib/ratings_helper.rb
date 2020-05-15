module RatingsHelper
  class << self
    def handle_rating_update(post, ratings, weight: 1)
      ratings.each do |rating|
        rating[:weight] = weight
      end
                  
      post.custom_fields['ratings'] = ratings
      post.save_custom_fields(true)
      
      update_topic(post.topic)
      push_ratings_to_clients(post)
    end

    def aggregate_rating_array(topic)
      topic.posts.map { |p| p.ratings }.flatten
    end

    def filter_by_type(ratings, type)
      ratings.select do |rating|
        if rating && rating[:weight].to_i === 1
          rating[:type] == type.to_s
        else
          false
        end
      end
    end

    def average_rating(ratings)
      ratings.map { |rating| rating[:value].to_i }.inject(:+) / ratings.length
    end

    def rating_count(ratings)
      ratings.length
    end

    def update_topic(topic)
      rating_types = topic.category.rating_types
      rating_array = aggregate_rating_array(topic)
      
      return if rating_types.blank? || rating_array.blank?
      
      ratings = []
      
      rating_types.each do |type|
        type_ratings = filter_by_type(rating_array, type)
        
        ratings.push(
          type: type,
          count: rating_count(type_ratings),
          value: average_rating(type_ratings)
        )
      end

      topic.custom_fields['ratings'] = ratings
      topic.save_custom_fields(true)
    end

    def push_ratings_to_clients(post)
      post.publish_change_to_clients!("ratings", topic_ratings: post.topic.ratings)
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
