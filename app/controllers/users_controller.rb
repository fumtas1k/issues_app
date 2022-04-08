class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :ensure_correct_mentor, only: :index
  before_action :set_user, only: %i[show stocked]
  before_action :ensure_correct_user, only: %i[show stocked]

  def index
    @users = User.includes(:groupings).with_attached_avatar.order(:code)
  end

  def show
    @issues =
      if @user.mentor
        @user.group_member_issues
      else
        @user.issues
      end.includes(:favorites).order(created_at: :desc)
  end

  def stocked
    @issues = @user.stock_issues.includes(:stocks).order(created_at: :desc)
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
