require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

require 'devise'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # データベースクリーナー関連とfactorybot
  config.before(:suite){DatabaseCleaner.strategy = :truncation}
  config.before(:all){DatabaseCleaner.start}
  config.after(:all){DatabaseCleaner.clean}
  config.include FactoryBot::Syntax::Methods

  # devise関連のrspec
  config.include Devise::Test::IntegrationHelpers, type: :system

  # action_textのヘルパー
  config.include ActionTextHelper, type: :system
end
