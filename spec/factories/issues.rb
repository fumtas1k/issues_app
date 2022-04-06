FactoryBot.define do
  factory :issue do
    title       { "ways to eliminate war" }
    description { "I hope wars will disappear from this world. but..." }
    status      {Issue.statuses.keys.first}
    scope       {Issue.scopes.keys.first}
    user
  end
end
