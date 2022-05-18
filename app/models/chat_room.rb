class ChatRoom < ApplicationRecord
  has_many :chat_room_users, dependent: :destroy
  has_many :users, through: :chat_room_users, source: :user
  has_many :messages, dependent: :destroy
end
