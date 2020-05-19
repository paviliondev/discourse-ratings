DiscourseRatings::Engine.routes.draw do
  scope constraints: AdminConstraint.new do
    resources :rating_type, param: :slug, :path => '/rating-type'
    resources :object, param: :type
  end
end

Discourse::Application.routes.append do
  get '/admin/plugins/ratings' => 'admin/plugins#index', constraints: AdminConstraint.new
  mount ::DiscourseRatings::Engine, at: "rating"
end