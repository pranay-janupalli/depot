Rails.application.routes.draw do
  
  resources :order_items
  resources :orders
  resources :line_items
  resources :carts
  root "products#index"
  put "/line_items_dec", to: "line_items#decrease", as: "line_items_dec"

  resources :products
  

  # get "/products", to: "products#index"
  # get "/products/:id", to: "products#show"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
