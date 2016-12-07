Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :plans, only: [:create, :destroy]
      resources :tokens, only: [:create]
      resources :searches, only: [:create]
    end
  end
end
