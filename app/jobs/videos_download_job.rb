class VideosDownloadJob < ApplicationJob
  queue_as :video

  #
  # ジョブを実行する
  #
  # @param archive [Archive]
  def perform(archive_id)
    archive = Archive.find(archive_id)
    archive.update_video()
  end
end
