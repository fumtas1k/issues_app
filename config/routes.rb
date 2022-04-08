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
    resources :users, only: %i[index show]
  end

  resources :issues
  resources :groupings, only: %i[create destroy]

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
