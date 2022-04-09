FactoryBot.define do
  factory :stock do
    user
    association :issue, :seq
  end
end
