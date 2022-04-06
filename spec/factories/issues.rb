FactoryBot.define do
  factory :issue do
    title { "MyString" }
    status { 1 }
    scope { 1 }
    user { nil }
  end
end
