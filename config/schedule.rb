rails_env = ENV["RAILS_ENV"] || "production"
set :output, 'log/crontab.log'
set :environment, rails_env

ENV.each {|k, v| env(k, v)} if rails_env == "development"

every "0 0 * * *" do
  rake "heroku_scheduler:delete_notification"
end

every "0 1 * * *" do
  rake "heroku_scheduler:purge_unattached"
end
