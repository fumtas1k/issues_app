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
      member do
        get :stocked
        get :mentor
        get :edit_avatar
      end
      resources :notifications, only: %i[index update] do
        collection do
          patch :read_all
          delete :destroy_all
        end
      end
    end
  end

  resources :users_csv, only: %i[create index]

  resources :issues do
    resources :favorites, only: %i[create destroy]
    resources :stocks, only: %i[create destroy]
    resources :comments, only: %i[create edit update destroy]
  end
  resources :groupings, only: %i[create destroy]

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
