FactoryBot.define do
  factory :user do
    name      { "firstuser" }
    code      { "000001" }
    email     { "first@diver.com" }
    entered_at{ Date.new(Date.current.year, 4, 1) }
    password  { "password" }

    trait :seq do
      sequence :name, "user01"
      sequence :code, "100001"
      sequence :email, "user01@diver.com"
    end

  end

  factory :mentor, class: User do
    name    { "mentor" }
    code    { "200001" }
    email   { "mentor@diver.com" }
    entered_at { Date.new(2020, 4, 1) }
    password{ "password" }
    mentor  { true }
  end

  factory :admin, class: User do
    name    { "admin" }
    code    { "300001" }
    email   { "admin@diver.com" }
    entered_at { Date.new(2014, 4, 1) }
    password{ "password" }
    mentor  { true }
    admin   { true }
  end

end
