module PostsControllerRatingsExtension
  def update
    params.require(:post)
    if SiteSetting.rating_enabled && params[:post][:ratings]      
      begin
        PostRevisor.ratings = JSON.parse(params[:post][:ratings])
      rescue JSON::ParserError
      end
    end
    super
  end
end