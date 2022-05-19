# Be sure to restart your server when you modify this file.

ActiveSupport::Reloader.to_prepare do
  if Rails.env.production?
    ApplicationController.renderer.defaults.merge!(
      http_host: "warm-scrubland-25965.herokuapp.com",
      https: true
    )
  else
    ApplicationController.renderer.defaults.merge!(
      http_host: "localhost:3000",
      https: false
    )
  end
end
