Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/twitter/callback', to: 'sessions#create'

  root 'home#index'
end
