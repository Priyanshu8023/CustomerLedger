Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Authentication
  post "/signup",  to:  "users#create"
  post "/login",   to:  "authentication#login"
  post "/logout",  to:  "authentication#logout"

  # Dashboard
  get "/dashboard", to: "dashboard#show"

  # Customers CRUD + summary
  resources :customers, path: "customer", controller: "customers", only: %i[index show create update destroy]

  resources :customers do
    member do
      get :summary
    end
  end

  # Orders + summary
  resources :orders do
    collection do
      get :summary
    end
  end

  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"
end
