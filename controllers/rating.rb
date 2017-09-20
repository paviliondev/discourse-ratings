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
    PostCustomField.destroy_all(post_id: id, name: "rating")
    PostCustomField.destroy_all(post_id: id, name: "rating_weight")

    average = RatingsHelper.calculate_topic_average(post.topic)
    RatingsHelper.push_ratings_to_clients(post.topic, average, post.id)
    render json: success_json
  end
end
