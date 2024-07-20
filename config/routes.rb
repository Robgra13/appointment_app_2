Rails.application.routes.draw do

  root "rooms#index"
  resources :rooms
  resources :bookings
  post 'chat/ask', to: 'chat#ask'
end
