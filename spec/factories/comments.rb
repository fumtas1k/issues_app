FactoryBot.define do
  factory :comment do
    content  { "Great just isn't good enough!" }
    user
    association :issue, :seq
  end
end
