Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/auth/twitter/callback', to: 'sessions#create'

  post '/new', to: 'home#new'
  get '/_timeline', to: 'home#_timeline'

  get '/:screen_name', to: 'home#profile'

  root 'home#index'
end
