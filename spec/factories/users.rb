FactoryBot.define do
  factory :user do
    name      { "firstuser" }
    code      { "900001" }
    email     { "first@diver.com" }
    entered_at{ Date.new(Date.current.year, 4, 1) }
    password  { "password" }
    password_confirmation { "password" }

    trait :seq do
      sequence :name, "user01"
      sequence :code, "990001"
      sequence :email, "user01@diver.com"
    end

  end

  factory :mentor, class: User do
    name    { "mentor" }
    code    { "200001" }
    email   { "mentor@diver.com" }
    entered_at { Date.new(2020, 4, 1) }
    password{ "password" }
    password_confirmation { "password" }
    mentor  { true }
  end

  factory :admin, class: User do
    name    { "admin" }
    code    { "100001" }
    email   { "admin@diver.com" }
    entered_at { Date.new(2014, 4, 1) }
    password{ "password" }
    password_confirmation { "password" }
    mentor  { true }
    admin   { true }
  end

end
