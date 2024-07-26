Rails.application.routes.draw do
  get 'errors/not_found'
  get 'testing/test'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check



  root "sessions#new"



  resources :users, except: [:new]


  get "/signup" => "users#new"
  post "/signup" => "users#create"

  get "/login" => "sessions#new"
  post "/login" => "sessions#create"

  get "/logout" => "sessions#destroy"

  resources :page , only: [:index]

  get "/admin_page" => "admin_page#index"
  get "/users_admin" => "profile#index"

  # get "/profile/:id" => "page#show", as: "visit_profile"
  # put "/profile/:id/edit" => "admin_page#profile_edit"

  resources :profile
  resources :problem
  get "get_problems" => "problem#get_problems"
  post "/filter" => "problem#filter"
  post "/submit_problem" => "problem#submit"

  get "leaderboard" => "page#leaderboard"


  # Catch-all route for handling unmatched routes for 404 error handling
  match '*path', to: 'errors#not_found', via: :all, constraints: lambda { |req| req.path.exclude?('/rails/active_storage') }

end
