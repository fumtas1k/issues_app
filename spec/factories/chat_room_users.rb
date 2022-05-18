FactoryBot.define do
  factory :chat_room_user do
    association :user, :seq
    chat_room
  end
end
