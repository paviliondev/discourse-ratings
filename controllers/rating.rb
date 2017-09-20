class DiscourseRatings::RatingController < ::ApplicationController
  def rate
    params.require(:id)
    params.require(:rating)

    post = Post.find(params[:id].to_i)
    post.custom_fields["rating"] = params[:rating].to_i
    post.custom_fields["rating_weight"] = 1
    post.save_custom_fields(true)

    handle_rating_update(post)

    render json: success_json
  end

  def remove
    params.require(:id)

    id = params[:id].to_i
    post = Post.find(id)
    PostCustomField.destroy_all(post_id: id, name: "rating")
    PostCustomField.destroy_all(post_id: id, name: "rating_weight")

    handle_rating_update(post)

    render json: success_json
  end
end
