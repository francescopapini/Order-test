Rails.application.routes.draw do
  resources :orders do
collection { post :import}
  end

  root to: 'orders#index'
end
