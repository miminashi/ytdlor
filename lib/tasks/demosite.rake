namespace :demosite do
  desc "Task for demo site"
  task autoremove: :environment do
    interval = (ENV["YTDLOR_AUTOREMOVE_INTERVAL"] || 15).to_i
    Archive
      .order({:id => :asc})
      .offset(2)
      .where({:status => Archive::Status::DONE})
      .where("updated_at < ?", interval.to_i.minutes.ago)
      .destroy_all

    interval = (ENV["YTDLOR_AUTOREMOVE_FAILED_INTERVAL"] || 60).to_i
    Archive
      .order({:id => :asc})
      .offset(2)
      .where("updated_at < ?", interval.to_i.minutes.ago)
      .destroy_all
  end
end
