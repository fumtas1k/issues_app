FactoryBot.define do
  factory :group do
    association :user, factory: :mentor
  end
end
