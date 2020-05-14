DiscourseRatings::Engine.routes.draw do
  post "/rate" => "rating#rate"
  post "/remove" => "rating#remove"
  resources :rating_type, constraints: StaffConstraint.new, param: :slug, :path => '/rating-type'
end

Discourse::Application.routes.append do
  get '/admin/plugins/rating-types' => 'admin/plugins#index', constraints: StaffConstraint.new
  mount ::DiscourseRatings::Engine, at: "rating"
end