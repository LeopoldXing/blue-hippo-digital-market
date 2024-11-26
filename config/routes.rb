Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # user auth
  post "/api/user/sign-up", to: "users#sign_up"
  post "/api/user/sign-in", to: "users#sign_in"
  post "/api/user/sign-out", to: "users#sign_out"

  # product
  get "/api/product/search", to: "products#search"
end
