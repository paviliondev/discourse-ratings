DiscourseRatings::Engine.routes.draw do
  scope constraints: AdminConstraint.new do
    resources :rating_type, param: :type, :path => '/rating-type'
    post "/rating-type/migrate" => "rating_type#migrate"
    resources :object, param: :type
  end
end

Discourse::Application.routes.append do
  get '/admin/plugins/ratings' => 'admin/plugins#index', constraints: AdminConstraint.new
  mount ::DiscourseRatings::Engine, at: "rating"
end