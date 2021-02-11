# frozen_string_literal: true
module PostsControllerRatingsExtension
  def update
    params.require(:post)
    if SiteSetting.rating_enabled && params[:id] && params[:post][:ratings]
      begin
        begin
          raw_ratings = JSON.parse(params[:post][:ratings])
        rescue JSON::ParserError
          raw_ratings = []
        end

        if raw_ratings.present?
          ratings = DiscourseRatings::Rating.build_list(raw_ratings)
          DiscourseRatings::Cache.new("update_#{params[:id]}").write(ratings)
        end
      rescue JSON::ParserError
      end
    end
    super
  end
end
