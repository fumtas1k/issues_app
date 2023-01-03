rails_env = ENV["RAILS_ENV"] || "production"
set :output, 'log/crontab.log'
set :environment, rails_env

ENV.each {|k, v| env(k, v)} if rails_env == "development"

# テスト用に時間を変更revertする
every "45 15 * * *" do
  rake "heroku_scheduler:delete_notification"
end

every "40 15 * * *" do
  rake "heroku_scheduler:purge_unattached"
end
