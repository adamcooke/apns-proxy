Rails.application.routes.draw do

  post 'api/notify' => 'api#notify'
  post 'api/register' => 'api#register'
  post 'api/add_auth_key' => 'api#add_auth_key'
  post 'api/remove_auth_key' => 'api#remove_auth_key'

  resources :applications do
    resources :environments
    resources :auth_keys
    resources :notifications do
      post :resend, :on => :member
    end
  end
  resources :devices, :only => [:show]
  resources :users

  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  root :to => 'dashboard#index'

end
