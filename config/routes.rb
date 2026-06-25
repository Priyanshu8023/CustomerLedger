Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "/signup",  to:  "users#create"
  post "/login",   to:  "authentication#login"
  
  post "/customer", to: "customers#create"
  get "/customer", to: "customers#index"
  get "/customer/:id", to: "customers#show"
  patch "/customer/:id", to: "customers#update"
  put "/customer/:id", to: "customers#update"
  delete "/customer/:id", to: "customers#destroy"
end
