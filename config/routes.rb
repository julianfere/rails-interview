Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists
    resources :todo_items, path: :todoitems
  end

  resources :todo_lists, only: %i[index new], path: :todolists
end
