Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "kraken#index"

	match '/', to: 'kraken#index', via: [:get, :post], :as => :home
	match '/button', to: 'kraken#button', via: [:get, :post], :as => :button
end
