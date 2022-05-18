class ChatRoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id).order_by_code
  end

  def show
    @chat_room = ChatRoom.find(params[:id])
    @chat_room_user = @chat_room.users.where.not(id: current_user.id).first
  end

  def create
    current_user_chat_room_ids = current_user.chat_rooms.pluck(:chat_room_id)
    chat_room = ChatRoomUser.find_by(chat_room_id: current_user_chat_room_ids, user_id: params[:user_id])&.chat_room
    if chat_room.blank?
      chat_room = ChatRoom.create
      chat_room.chat_room_users.create(user_id: current_user.id)
      chat_room.chat_room_users.create(user_id: params[:user_id])
    end
    redirect_to user_chat_room_path(current_user, chat_room)
  end
end
