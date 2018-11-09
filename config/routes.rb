Rails.application.routes.draw do
  root 'user#show'
  devise_for :users
  get 'user/get'
  get 'user/get_confirm', to: 'user#get_confirm', as: 'user_get_confirm'
  post'user/create_follow', to: 'user#create_follow', as: 'user_create_follow'
  get 'rooms/show', to: 'rooms#show', as: 'rooms_show'
  get 'rooms/new'
  post'rooms/create_group'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
