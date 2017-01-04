Rails.application.routes.draw do
  resources :password_resets, only: [:create, :update]

  namespace :api do
    namespace :v1 do
      resources :user_confirmation, only: [:create, :update]
      resources :plans, only: [:create, :destroy]
      resources :tokens, only: [:create]
      resources :searches, only: [:create]
      resources :users, only: [:create, :update, :destroy]
    end
  end
end
