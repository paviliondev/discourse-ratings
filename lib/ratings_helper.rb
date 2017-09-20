module RatingsHelper
  class << self
    def handle_rating_update(post)
      average = calculate_topic_average(post.topic)
      push_ratings_to_clients(post.topic, average, post.id)
    end

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

    def push_ratings_to_clients(topic, average, updatedId = '')
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
