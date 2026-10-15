# frozen_string_literal: true

class Users::MentorRolesController < ApplicationController
  before_action :authenticate_user!
  rescue_from CanCan::AccessDenied, with: :access_denied

  # PATCH /users/:user_id/mentor_role
  def update
    @user = User.find(params[:user_id])
    authorize! :toggle_mentor, @user
    @user.toggle!(:mentor)
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render "users/role_change" }
    end
  end

  private

  def access_denied
    respond_to do |format|
      format.html do
        flash[:danger] = I18n.t("views.users.flash.access_denied")
        redirect_to root_path
      end
      format.js { head :forbidden }
    end
  end
end
