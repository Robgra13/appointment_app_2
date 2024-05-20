Rails.application.routes.draw do

  root "rooms#index"
  resources :rooms
  resources :bookings
end
