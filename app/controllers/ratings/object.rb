# frozen_string_literal: true
class DiscourseRatings::ObjectController < ::Admin::AdminController
  before_action :validate_type
  before_action :validate_object, only: [:create]

  def show
    render_serialized(
      DiscourseRatings::Object.list(params[:type]),
      DiscourseRatings::ObjectSerializer,
    )
  end

  def create
    handle_render(
      DiscourseRatings::Object.create(params[:type], object_params[:name], object_params[:types]),
    )
  end

  def update
    handle_render(
      DiscourseRatings::Object.set(params[:type], object_params[:name], object_params[:types]),
    )
  end

  def destroy
    handle_render(DiscourseRatings::Object.destroy(params[:type], object_params[:name]))
  end

  private

  def object_params
    params.permit(:name, types: [])
  end

  def validate_type
    unless DiscourseRatings::Object::TYPES.include?(params[:type])
      raise Discourse::InvalidParameters.new(:type)
    end
  end

  def validate_object
    if DiscourseRatings::Object.exists?(params[:type], object_params[:name])
      raise Discourse::InvalidParameters.new(:name)
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
