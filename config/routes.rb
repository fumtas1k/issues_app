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

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
