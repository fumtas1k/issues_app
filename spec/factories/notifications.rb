FactoryBot.define do
  factory :notification do
    subject { issue }
    user
    message { "create issue!" }
    link_path { issue_path(issue) }
    read { false }
  end
end
