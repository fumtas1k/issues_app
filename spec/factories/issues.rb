FactoryBot.define do
  srand(1234)

  factory :issue do
    title       { "ways to eliminate war" }
    description { "I hope wars will disappear from this world. but..." }
    status      {Issue.statuses.keys.first}
    scope       {Issue.scopes.keys.first}
    user

    trait :limited do
      scope     { :limited }
    end

    trait :draft do
      scope     { :draft }
    end

    trait :solving do
      status    { :solving }
    end
  end

  factory :issue_rand, class: Issue do
    title       { Faker::Games::Pokemon.name[0,20] }
    description { Faker::Hacker.say_something_smart }
    status      { Issue.statuses.keys[rand(2)] }
    scope       { Issue.scopes.keys[rand(3)] }
    user

    trait :limited do
      scope     { :limited }
    end

    trait :draft do
      scope     { :draft }
    end

    trait :solving do
      status    { :solving }
    end
  end
end
