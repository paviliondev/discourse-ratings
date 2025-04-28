# frozen_string_literal: true
class DiscourseRatings::RatingController < ::Admin::AdminController
  before_action :check_types_exist

  def migrate
    handle_render(
      Jobs.enqueue(
        :migrate_ratings,
        category_id: rating_params[:category_id],
        type: rating_params[:type],
        new_type: rating_params[:new_type],
      ),
    )
  end

  def destroy
    handle_render(
      Jobs.enqueue(
        :destroy_ratings,
        category_id: rating_params[:category_id],
        type: rating_params[:type],
      ),
    )
  end

  private

  def rating_params
    params.permit(:category_id, :type, :new_type)
  end

  def check_types_exist
    if !DiscourseRatings::RatingType.exists?(rating_params[:type])
      raise Discourse::InvalidParameters.new(:type)
    end

    if action_name == "migrate" && !DiscourseRatings::RatingType.exists?(rating_params[:new_type])
      raise Discourse::InvalidParameters.new(:new_type)
    end
  end

  def handle_render(success)
    if success
      render_json_dump(success_json)
    else
      render_json_dump(failed_json)
    end
  end
end
