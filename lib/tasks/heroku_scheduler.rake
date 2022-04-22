namespace :heroku_scheduler do
	desc "This task is called by the Heroku scheduler add-on"

	task test_scheduler: :environment do
	  puts "scheduler test"
	  puts "it works."
	end

	task purge_unattached: :environment do
	  ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at <= ?", 1.day.ago)
	  .find_each(&:purge)
	end

  task delete_notification: :environment do
		Notification.where("created_at <= ?", 7.days.ago).destroy_all
  end
end
