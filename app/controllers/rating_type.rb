class DiscourseRatings::RatingTypeController < ::ApplicationController  
  before_action :check_type_exists, only: [:update, :destroy]
  before_action :validate_name, only: [:update, :create]
  before_action :validate_slug, only: [:create]
  
  MIN_SLUG_LENGTH = 2
  MIN_NAME_LENGTH = 2
  
  def index
    render_serialized(DiscourseRatings::RatingType.all, DiscourseRatings::RatingTypeSerializer)
  end
  
  def create
    handle_render(DiscourseRatings::RatingType.create(type_params[:slug], type_params[:name]))
  end
  
  def update
    handle_render(DiscourseRatings::RatingType.set(params[:slug], type_params[:name]))
  end

  def destroy
    handle_render(DiscourseRatings::RatingType.destroy(params[:slug]))
  end
  
  private
  
  def type_params
    params.require(:type).permit(:slug, :name)
  end
  
  def validate_slug
    if type_params[:slug].length < MIN_SLUG_LENGTH || 
       type_params[:slug] == DiscourseRatings::RatingType::NONE
      
      raise Discourse::InvalidParameters.new(:slug)
    end
  end
  
  def validate_name
    if type_params[:name].length < MIN_NAME_LENGTH
      raise Discourse::InvalidParameters.new(:name)
    end
  end
  
  def check_type_exists
    unless DiscourseRatings::RatingType.exists?(params[:slug])
      raise Discourse::InvalidParameters.new(:slug) 
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
