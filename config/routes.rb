Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, path: :todolists do
      resources :todo_items, path: :todoitems
    end
  end

  resources :todo_lists, path: :todolists do
    resources :todo_items, only: %i[new create edit update destroy]
  end

  root "todo_lists#index"
end
