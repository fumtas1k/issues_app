class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    chat_room = ChatRoom.find_by(id: params[:chat_room_id])
    user = User.find_by(id: params[:user_id])
    stream_for [user, chat_room] if chat_room.present? && user.present?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    return if data["message"].blank?
    Message.create!(
      content: data["message"],
      read: false,
      user_id: current_user.id,
      chat_room_id: data["chat_room_id"]
    )
  end

  def read(data)
    returen if data["message_id"].blank?
    message = Message.find(data["message_id"]);
    chat_room = message.chat_room
    current_user = message.user

    MessageReadUpdateJob.perform_later(current_user, chat_room)
  end
end
