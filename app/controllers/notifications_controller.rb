class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: :index

  def index
    @user = User.find(params[:user_id])
    @notifications = @user.notifications.order(created_at: :desc)
  end

  def update
    @notification = Notification.find(params[:id])
    @notification.toggle!(:read) unless @notification.read?
    redirect_to @notification.link_path
  end

  def read_all
    user = User.find(params[:user_id])
    @notifications = user.notifications
    @notifications.unreads.each{ _1.toggle!(:read) }
    redirect_to user_notifications_path(user)
  end

  def destroy_all
    user = User.find(params[:user_id])
    @notifications = user.notifications
    if @notifications.present?
      @notifications.destroy_all
      flash[:danger] = I18n.t("views.notifications.flash.delete_all")
    end
    redirect_to user_notifications_path(user)
  end

  private

  def ensure_correct_user
    user = User.find(params[:user_id])
    redirect_back fallback_location: root_path unless current_user == user
  end
end
