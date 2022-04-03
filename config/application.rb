require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module IssuesApp
  class Application < Rails::Application
    config.load_defaults 6.0
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    config.generators do |g|
      g.assets false          # <= css,javascriptファイルを作成しない
      g.helper false          # <= helperファイルを作成しない
      g.skip_routes true      # <= routes.rbを変更しない
    end

    config.generators do |g|
      g.test_framework :rspec,
      fixtures: true,
      view_specs: false,
      helper_specs: false,
      routing_specs: false,
      controller_specs: false,
      request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end
  end
end
