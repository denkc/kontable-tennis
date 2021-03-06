Pong::Application.routes.draw do

  resources :tags

  devise_for :admins, :controllers => { :omniauth_callbacks => "admins/sessions" }

  devise_scope :admin do
    match '/admins/auth/google/callback' => 'admins/sessions#callback'
    get '/admins/sign_out' => 'devise/sessions#destroy'
  end

  resources :matches
  resources :players

  match '/distribution' => 'players#distribution', :as => 'distribution'
  match '/vs_table' => 'players#vs_table', :as => 'vs_table'

  root to: 'players#rankings'
end
