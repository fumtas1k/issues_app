source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'rails', '~> 6.0.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'image_processing'
gem 'bootsnap', '>= 1.4.2', require: false

gem 'actiontext'
gem 'activerecord-import'
gem 'acts-as-taggable-on'
gem 'aws-sdk-s3', require: false
gem 'cancancan'
gem 'devise'
gem 'devise-i18n'
gem 'dotenv-rails'
gem 'faker'
gem 'kaminari'
gem 'rails_admin'
gem 'ransack'
gem 'redis', '~> 4'
gem 'rexml'
gem 'sendgrid-ruby'
gem 'unicorn'
gem 'whenever', require: false

group :development, :test do
  gem 'bcrypt_pbkdf'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capistrano', require: false
  gem 'capistrano3-unicorn', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rbenv', require: false
  gem 'ed25519'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :development do
  gem 'letter_opener_web'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
