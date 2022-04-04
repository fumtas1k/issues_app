class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :mentor_required, only: %i[index]

  def index
    @users = User.all.with_attached_avatar
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def mentor_required
    redirect_back(fallback_location: root_path) unless current_user&.mentor
  end
end
