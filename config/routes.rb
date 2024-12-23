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
  get "/api/user", to: "users#get_current_user"

  # product
  get "/api/product/search", to: "products#search"
  get '/api/product/:id', to: 'products#get_product', as: :get_product
  post "/api/product", to: "products#create_product", as: :create_product
  delete "/api/product/:payload_id", to: "products#delete_product", as: :delete_product
  put "/api/product", to: "products#update_product", as: :update_product

  # route
  get "/api/cart", to: "cart#get_cart", as: :get_cart
  post "/api/cart/:product_id", to: "cart#create", as: :create_cart_item
  delete "/api/cart/:product_id", to: "cart#destroy", as: :destroy_cart_item
  delete "/api/cart/clear", to: "cart#clear", as: :clear_cart

  # order
  post "/api/stripe/payment/checkout-session", to: "orders#create_checkout_session", as: :create_checkout_session
  get "/api/stripe/order/:order_id", to: "orders#get_order", as: :get_order
end
