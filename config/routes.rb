Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    get 'login', to: 'devise/sessions#new'
    get 'signup', to: 'devise/registrations#create'
  end

  get :dashboard, to: 'pages#dashboard'

  resources :clients, only: %i[ new create edit update index destroy ]

  resources :invoices do
    member do
      get :pdf
      post :mark_as_paid
      post :mark_as_unpaid
    end
  end
end
