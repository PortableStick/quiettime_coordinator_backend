Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/login', to: 'tokens#create'
      post '/search', to: 'searches#create'
      patch '/attending', to: 'searches#update'
      delete '/attending/:yelp_id', to: 'searches#destroy'
    end
  end
end
