Rails.application.routes.draw do
  root "home#index"
  # post "vote", to: "home#vote"
  # post "reset", to: "home#reset"
  # post "reset_ugly", to: "home#reset_ugly"
  # post "reset_nice", to: "home#reset_nice"
  # post "/update_position", to: "home#update_position"

  get "color_ranker/rank_colors"
  get "/rank_colors", to: "color_ranker#rank_colors"
  post "vote_color", to: "color_ranker#vote_color"
  post "reset_colors", to: "color_ranker#reset_colors"
  post "reset_ugly_colors", to: "color_ranker#reset_ugly_colors"
  post "reset_nice_colors", to: "color_ranker#reset_nice_colors"
  post "/color_ranker/update_position", to: "color_ranker#update_position"

  get "pairs/rank_color_pairs"
  get "/rank_color_pairs", to: "pairs#rank_color_pairs"
  post '/vote_pair', to: 'pairs#vote_pair'
  post "reset_pairs", to: "pairs#reset_pairs"
  post "reset_ugly_pairs", to: "pairs#reset_ugly_pairs"
  post "reset_nice_pairs", to: "pairs#reset_nice_pairs"
  post '/pairs/update_position', to: 'pairs#update_position'

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
