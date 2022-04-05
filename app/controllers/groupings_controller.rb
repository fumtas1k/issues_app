class GroupingsController < ApplicationController
  def create
    current_user.group.groupings.create!(user_id: params[:member_id])
    redirect_to users_path
  end

  def destroy
    Grouping.find(params[:id]).destroy
    redirect_to users_path
  end
end
