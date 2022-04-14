class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :ensure_correct_mentor, only: :index
  before_action :set_user, only: %i[show stocked]
  before_action :ensure_correct_user, only: %i[show stocked]

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).includes(:groupings).with_attached_avatar.order(:code).page(params[:page])
  end

  def show
    @issues =
      if @user.mentor
        @issues = @user.group_member_issues
        params[:issue_user_id].present? ? @issues.where(user_id: params[:issue_user_id]) : @issues
      else
        @user.issues
      end&.includes(:favorites)&.recent
  end

  def stocked
    @issues = @user.stock_issues.includes(:stocks).recent
    @issues = @issues.where(user_id: params[:issue_user_id]) if params[:issue_user_id].present?
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_correct_mentor
    redirect_back fallback_location: root_path unless current_user&.mentor
  end

  def ensure_correct_user
    set_user
    redirect_back fallback_location: root_path unless current_user == @user
  end
end
