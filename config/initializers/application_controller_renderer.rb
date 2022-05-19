# Be sure to restart your server when you modify this file.

ActiveSupport::Reloader.to_prepare do
  ApplicationController.renderer.defaults.merge!(
    if Rails.env.production?
      http_host: "warm-scrubland-25965.herokuapp.com"
      https: true
    else
      http_host: "localhost:3000"
      https: false
    end
  )
end
