# frozen_string_literal: true
class AddRatingTypes < ActiveRecord::Migration[6.0]
  def up
    Post.reset_column_information
    Topic.reset_column_information

    posts = Post.where("id in (SELECT post_id from post_custom_fields where name = 'rating')")
    topics = Topic.where(id: posts.pluck(:topic_id).uniq)

    posts.each do |post|
      rating = {
        type: DiscourseRatings::RatingType::NONE,
        value: post.custom_fields["rating"],
        weight: post.custom_fields["rating_weight"],
      }
      DiscourseRatings::Rating.build_and_set(post, rating)
      post.save_custom_fields(true)
    end

    topics.each do |topic|
      rating = {
        type: DiscourseRatings::RatingType::NONE,
        value: topic.custom_fields["average_rating"],
        count: topic.custom_fields["rating_count"],
      }
      DiscourseRatings::Rating.build_and_set(topic, rating)
      topic.save_custom_fields(true)
    end

    CategoryCustomField
      .where(name: "rating_enabled")
      .each do |row|
        if ActiveModel::Type::Boolean.new.cast(row.value)
          if category = Category.find(row.category_id)
            DiscourseRatings::Object.create(
              "category",
              category.rating_key,
              [DiscourseRatings::RatingType::NONE],
            )
          end
        end
      end
  end

  def down
  end
end
