class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    chat_room = ChatRoom.find(message.chat_room_id)
    broadcast(message, chat_room)
  end

  private

  def render_message(message, user)
    renderer = ApplicationController.renderer.new
    renderer.render(
      partial: "messages/message",
      locals: {
        message: message,
        current_user: user,
      }
    )
  end

  def broadcast(message, chat_room)
    users = chat_room.users
    2.times do |i|
      check_read = (message.user.id != users[i].id)
      ChatRoomChannel.broadcast_to(
        [users[i], chat_room],
        {message: render_message(message, users[i]), check_read: check_read, message_id: message.id}
      )
    end
  end
end
