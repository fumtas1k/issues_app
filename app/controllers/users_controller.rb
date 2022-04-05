class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :mentor_required, only: :index

  def index
    @users = User.includes(:groupings).with_attached_avatar
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def mentor_required
    redirect_to root_path unless current_user&.mentor
  end
end
