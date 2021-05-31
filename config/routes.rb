Rails.application.routes.draw do
  
  resources :line_items
  resources :carts
  root "products#index"

  resources :products
  

  # get "/products", to: "products#index"
  # get "/products/:id", to: "products#show"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
