class GroupingsController < ApplicationController
  def create
    @user = User.find(params[:member_id])
    respond_to do |format|
      current_user.group.groupings.create!(user_id: @user.id)
      format.html {redirect_to users_path}
      format.js {render "member_change"}
    end
  end

  def destroy
    grouping = Grouping.find(params[:id])
    @user = grouping.user
    respond_to do |format|
      grouping.destroy
      format.html {redirect_to users_path}
      format.js {render "member_change"}
    end
  end
end
