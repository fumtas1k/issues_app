class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]

  def index
    @users = User.all.with_attached_avatar
  end

  def show
    @user = User.find(params[:id])
  end
end
