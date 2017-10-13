Rails.application.routes.draw do
  resources :stores
  resources :applications

  namespace :api do
    namespace :v1 do
      resources :search, only: [:index]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
