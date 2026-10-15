class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    # クライアントから送られた user_id は使わず、接続ユーザーが参加しているルームだけ購読を許可する
    @chat_room = current_user.chat_rooms.find_by(id: params[:chat_room_id])
    return reject if @chat_room.blank?
    stream_for [current_user, @chat_room]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    return if @chat_room.blank?
    return if data["message"].blank?
    # 送信者とルームは、購読時に検証したものを使う
    current_user.messages.create!(
      content: data["message"],
      read: false,
      chat_room: @chat_room
    )
  end

  def read(data)
    return if @chat_room.blank?
    return if data["message_id"].blank?
    # 購読中のルーム内の、相手のメッセージだけを対象にする
    message = @chat_room.messages.where.not(user_id: current_user.id).find_by(id: data["message_id"])
    return if message.blank?

    MessageReadUpdateJob.perform_later(message.user, @chat_room)
  end
end
