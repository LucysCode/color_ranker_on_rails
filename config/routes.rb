Rails.application.routes.draw do
  # For User Login
  require "devise"

  devise_for :users

  # root "home#index"
  root to: "home#index"
  get "/index", to: "home#index"

  # Single Colors
  get "color_ranker/rank_colors"
  get "/rank_colors", to: "color_ranker#rank_colors"
  post "vote_color", to: "color_ranker#vote_color"
  post "reset_colors", to: "color_ranker#reset_colors"
  post "reset_ugly_colors", to: "color_ranker#reset_ugly_colors"
  post "reset_nice_colors", to: "color_ranker#reset_nice_colors"
  post "/color_ranker/update_position", to: "color_ranker#update_position"

  # Pairs
  get "pairs/rank_color_pairs"
  get "/rank_color_pairs", to: "pairs#rank_color_pairs"
  post "/vote_pair", to: "pairs#vote_pair"
  post "reset_pairs", to: "pairs#reset_pairs"
  post "reset_ugly_pairs", to: "pairs#reset_ugly_pairs"
  post "reset_nice_pairs", to: "pairs#reset_nice_pairs"
  post "/pairs/update_position", to: "pairs#update_position"

  # My Votes
  get "/my_votes", to: "users#my_votes", as: :my_votes

# Delete for color votes
resources :color_votes, only: [ :create, :destroy ]
resources :color_pair_votes, only: [ :create, :destroy ]

  # config/routes.rb
  # resources :color_votes do
  #   collection { patch :sort }            # /color_votes/sort
  # end

  # resources :color_pair_votes do
  #   collection { patch :sort }            # /color_pair_votes/sort
  # end

  # get "/rank_color_pairs", to: "pages#index"


  # or
  # get '/', to: 'home#index' if you prefer

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
