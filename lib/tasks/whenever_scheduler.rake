require "logger"

# TODO これは本来設定ファイルか環境変数にすべき
LOG_FILE = "log/crontab.log"

namespace :whenever_scheduler do
  desc "This task is called by the whenever scheduler"

  schedule_logger = Logger.new(LOG_FILE)

  task test_scheduler: :environment do
    puts "scheduler test"
    puts "it works."
  end

  task purge_unattached: :environment do
    unattached_blobs = ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at <= ?", 1.day.ago)
    count = unattached_blobs.size
    unattached_blobs.find_each(&:purge)
    schedule_logger.info "[rake task] #{count}件のアタッチされていないファイルを削除しました!"
  end

  task delete_notification: :environment do
    old_notifications = Notification.where("created_at <= ?", 29.days.ago)
    count = old_notifications.size
    old_notifications.destroy_all
    schedule_logger.info "[rake task] #{count}件の古い通知を削除しました!"
  end
end
