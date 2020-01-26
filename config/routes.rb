Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/twitter/callback', to: 'sessions#create'

  get '/:screen_name', to: 'home#profile'
  post '/new', to: 'home#new'

  root 'home#index'
end
