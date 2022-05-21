class ChatRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: %i[show]

  def index
    @users = User.where.not(id: current_user.id).order_by_code
  end

  def show
    @chat_room = ChatRoom.find(params[:id])
    @partner = @chat_room.users.where.not(id: current_user.id).first
    @messages = @chat_room.messages.includes(:user).past
    @unread_id = @messages.where(user_id: @partner.id, read: false).past[0]&.id
    MessageReadUpdateJob.perform_later(@partner, @chat_room)
  end

  def create
    current_user_chat_room_ids = current_user.chat_rooms.pluck(:id)
    chat_room = ChatRoomUser.find_by(chat_room_id: current_user_chat_room_ids, user_id: params[:user_id])&.chat_room
    if chat_room.blank?
      chat_room = ChatRoom.create
      chat_room.chat_room_users.create(user_id: current_user.id)
      chat_room.chat_room_users.create(user_id: params[:user_id])
    end
    redirect_to user_chat_room_path(current_user, chat_room)
  end

  private

  def ensure_correct_user
    chat_room = ChatRoom.find(params[:id])
    redirect_back fallback_location: root_path unless chat_room.users.include?(current_user)
  end
end
