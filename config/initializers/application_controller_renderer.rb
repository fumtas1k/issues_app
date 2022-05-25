# Be sure to restart your server when you modify this file.

ActiveSupport::Reloader.to_prepare do
  if Rails.env.production?
    ApplicationController.renderer.defaults.merge!(
      http_host: ENV['HTTP_HOST'],
      https: ENV['HTTPS']
    )
  else
    ApplicationController.renderer.defaults.merge!(
      http_host: "localhost:3000",
      https: false
    )
  end
end
