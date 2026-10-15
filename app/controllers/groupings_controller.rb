class GroupingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_mentor_with_group

  def create
    @user = User.find(params[:member_id])
    respond_to do |format|
      current_user.group.groupings.create!(user_id: @user.id)
      format.html {redirect_to users_path}
      format.js {render "member_change"}
    end
  end

  def destroy
    grouping = current_user.group.groupings.find(params[:id])
    @user = grouping.user
    respond_to do |format|
      grouping.destroy
      format.html {redirect_to users_path}
      format.js {render "member_change"}
    end
  end

  private

  def ensure_mentor_with_group
    redirect_back fallback_location: root_path unless current_user.mentor? && current_user.group
  end
end
