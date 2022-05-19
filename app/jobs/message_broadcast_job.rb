class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    chat_room = ChatRoom.find(message.chat_room_id)
    broadcast(message, chat_room)
  end

  private

  def render_message(message, user)
    if Rails.env.production?
      http_host = "warm-scrubland-25965.herokuapp.com"
      https = "on"
    else
      http_host = "localhost:3000"
      https = "off"
    end
    renderer = ApplicationController.renderer.new
    renderer.instance_variable_set(:@env, renderer.instance_variable_get(:@env).merge("HTTP_HOST" => http_host, "HTTPS" => https))
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
      ChatRoomChannel.broadcast_to(
        [users[i], chat_room],
        {message: render_message(message, users[i])}
      )
    end
  end
end
