Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "works#root"

  #Omniauth login route
  get '/auth/github', as: 'github_login'

  #Omniauth call back route
  get '/auth/:provider/callback', to: 'users#create', as: 'omniauth_callback'

  post "/logout", to: "users#logout", as: "logout"

  resources :works
  post "/works/:id/upvote", to: "works#upvote", as: "upvote"

  resources :users, only: [:index, :show]
end
