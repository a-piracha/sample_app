Rails.application.routes.draw do
  get 'sessions/new'
  get 'users/new'
  root "static_pages#home"
  # get "static_pages/home"
  # get "static_pages/help"
  # get "static_pages/about"
  # get "static_pages/contact"

  get "/home", to:"static_pages#home"
  get "/help", to:"static_pages#help"
  get "/about", to:"static_pages#about"
  get "/contact", to:"static_pages#contact"
  get "/signup", to:"users#new"
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users
  resources :account_activations, only: [:edit]
  # resources :password_resets,
  # only: [:new, :create, :edit, :update]

  get "/password_resets/new", to: "password_resets#new", as: "new_password_reset"
  post "/password_resets", to: "password_resets#create", as: "create_password_reset"
  get "/password_resets/:id/edit", to: "password_resets#edit", as: "edit_password_reset"
  patch "/password_resets/:id", to: "password_resets#update", as: "password_reset"


  # post "/microposts", to:"microposts#create"
  # delete "/microposts/:id", to:"microposts#destroy"
  # routes for showing follwers and following
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :microposts, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  get '/microposts', to: 'static_pages#home'
end
