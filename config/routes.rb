Rails.application.routes.draw do
  root "home#index"
  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    # omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords",
    registrations: "users/registrations",
    sessions: "users/sessions"
    # unlocks: "users/unlocks"
  }
  devise_scope :user do
    post "users/guest_sign_in", to: "users/sessions#guest_sign_in"
    resources :users, only: %i[index show] do
      resources :notifications, only: %i[index update] do
        collection do
          patch :all_read
        end
      end
      member do
        get :stocked
      end
    end
  end

  resources :issues do
    resources :favorites, only: %i[create destroy]
    resources :stocks, only: %i[create destroy]
    resources :comments, only: %i[create edit update destroy]
  end
  resources :groupings, only: %i[create destroy]

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
