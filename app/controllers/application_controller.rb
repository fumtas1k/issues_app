class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :success, :info, :warning, :danger

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name email avatar avatar_blob_id mentor entered_at])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name email avatar avatar_blob_id mentor entered_at])
  end
end
