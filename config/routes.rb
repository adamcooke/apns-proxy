Rails.application.routes.draw do
  
  match 'api/:action', :controller => 'api', :via => [:get, :post]
  
  resources :applications do
    resources :environments
    resources :auth_keys
    resources :notifications do
      post :reattempt, :on => :member
    end
  end
  resources :devices, :only => [:show]
  resources :users
  
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  
  root :to => 'dashboard#index'
  
end
