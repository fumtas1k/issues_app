FactoryBot.define do
  factory :notification do
    association :subject, factory: :issue
    user
    message { "create issue!" }
    link_path { "link_path" }
    read { false }
  end
end
