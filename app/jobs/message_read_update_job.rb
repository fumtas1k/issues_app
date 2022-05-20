class MessageReadUpdateJob < ApplicationJob
  queue_as :default

  def perform(user, chat_room)
    now_read_messages = Message.where(user_id: user.id, chat_room_id: chat_room.id, read: false)
    read_message_ids = now_read_messages.pluck(:id)
    return if read_message_ids.blank?
    Message.read_all(now_read_messages)
    ChatRoomChannel.broadcast_to([user, chat_room], {read_message_ids: read_message_ids, change_read: Message.human_attribute_name(:read)})
  end
end
