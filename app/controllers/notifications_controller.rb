class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: :index

  def index
    @user = User.find(params[:user_id])
    @notifications = @user.notifications
  end

  private

  def ensure_correct_user
    user = User.find(params[:user_id])
    redirect_back fallback_location: root_path unless current_user == user
  end
end
