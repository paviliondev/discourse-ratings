class AddRatingTypes < ActiveRecord::Migration[6.0]
  def up
    posts = Post.where("id in (SELECT post_id from post_custom_fields where name = 'rating')")
    topics = Topic.where(id: posts.pluck(:topic_id).uniq)
    
    posts.each do |post|
      rating = {
        type: DiscourseRatings::RatingType::NONE,
        value: post.custom_fields["rating"],
        weight: post.custom_fields["rating_weight"]
      }
      ratings = DiscourseRatings::Rating.build_list(rating)
      DiscourseRatings::Rating.set_custom_fields(post, ratings)
      post.save_custom_fields(true)
    end
    
    topics.each do |topic|
      rating = {
        type: DiscourseRatings::RatingType::NONE,
        value: topic.custom_fields['average_rating'],
        count: topic.custom_fields['rating_count']
      }
      ratings = DiscourseRatings::Rating.build_list(rating)
      DiscourseRatings::Rating.set_custom_fields(topic, ratings)
      topic.save_custom_fields(true)
    end
  end

  def down
  end
end
