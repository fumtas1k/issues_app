FactoryBot.define do
  factory :favorite do
    user
    association :issue, :seq
  end
end
