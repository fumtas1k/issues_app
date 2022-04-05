# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  def guest_sign_in
    user = params[:admin] ? User.guest_user("admin") : User.guest_user
    sign_in user
    flash[:success] = params[:admin] ? I18n.t("devise.sessions.guest_admin_signed_in") : I18n.t("devise.sessions.guest_signed_in")
    redirect_to user_path(user)
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_in_path_for(resource)
    resource
  end

end
