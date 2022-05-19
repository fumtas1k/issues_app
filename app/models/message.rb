class Message < ApplicationRecord
  include SqlHelper
  belongs_to :user
  belongs_to :chat_room

  after_create_commit { MessageBroadcastJob.perform_later self}
  validates :content, presence: true
end
