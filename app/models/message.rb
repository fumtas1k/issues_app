class Message < ApplicationRecord
  include SqlHelper
  belongs_to :user
  belongs_to :chat_room, counter_cache: true

  after_create_commit { MessageBroadcastJob.perform_later self}
  validates :content, presence: true

  def self.read_all(ids)
    return if ids.blank?
    self.where(id: ids).each { _1.toggle!(:read) unless _1.read }
  end
end
