class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user

  def index
    @user = current_user
    @notifications = current_user.notifications.recent.page(params[:page])
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.toggle!(:read) unless @notification.read?
    redirect_to @notification.link_path
  end

  def read_all
    @notifications = current_user.notifications
    @notifications.unreads.each{ _1.toggle!(:read) }
    redirect_to user_notifications_path(current_user)
  end

  def destroy_all
    @notifications = current_user.notifications
    if @notifications.present?
      @notifications.destroy_all
      flash[:danger] = I18n.t("views.notifications.flash.delete_all")
    end
    redirect_to user_notifications_path(current_user)
  end

  private

  def ensure_correct_user
    # レコードの取得にはparams[:user_id]を使わず、URLの不整合だけを防ぐ
    redirect_back fallback_location: root_path unless params[:user_id].to_s == current_user.id.to_s
  end
end
