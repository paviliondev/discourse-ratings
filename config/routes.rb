DiscourseRatings::Engine.routes.draw do
  post "/rate" => "rating#rate"
  post "/remove" => "rating#remove"
  
  scope constraints: AdminConstraint.new do
    resources :rating_type, param: :slug, :path => '/rating-type'
    resources :object, param: :type
  end
end

Discourse::Application.routes.append do
  get '/admin/plugins/ratings' => 'admin/plugins#index', constraints: StaffConstraint.new
  mount ::DiscourseRatings::Engine, at: "rating"
end