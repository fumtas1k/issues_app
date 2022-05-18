FactoryBot.define do
  factory :message do
    association :user, :seq
    chat_room
    content { "Hello world!" }
    read { false }
  end
end
