class ChatRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: %i[show]

  def index
    @users = User.where.not(id: current_user.id).order_by_code
  end

  def show
    @chat_room = ChatRoom.find(params[:id])
    @partner = @chat_room.users.where.not(id: current_user.id).first
    @messages = @chat_room.messages.past
    @unread_index = nil
    @messages.each_with_index do |message, index|
      if message.user == @partner && !message.read
        @unread_index ||= index
        message.toggle!(:read)
      end
    end
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

def ensure_correct_user
  user = User.find(params[:user_id])
  redirect_back fallback_location: root_path unless current_user == user
end
