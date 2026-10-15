# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  before_action :reject_guest_email!, only: %i[create]
  before_action :reject_guest_token!, only: %i[update]

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private

  # ゲストのパスワードは再設定させない
  def reject_guest_email!
    email = params.dig(resource_name, :email).to_s.strip.downcase
    return unless User.find_by(email: email)&.guest?
    redirect_to new_user_password_path, flash: {danger: I18n.t("devise.passwords.guest_restricted")}
  end

  def reject_guest_token!
    token = params.dig(resource_name, :reset_password_token)
    return unless token.present? && User.with_reset_password_token(token)&.guest?
    redirect_to new_user_session_path, flash: {danger: I18n.t("devise.passwords.guest_restricted")}
  end
end
