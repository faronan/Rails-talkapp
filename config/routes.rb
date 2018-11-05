Rails.application.routes.draw do
  root 'user#show'
  devise_for :users
  get 'rooms/show/:id', to: 'rooms#show', as: 'rooms_show'
  get 'rooms/new'
  post 'rooms/create_group'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
