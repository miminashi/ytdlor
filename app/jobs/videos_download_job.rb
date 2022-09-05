class VideosDownloadJob < ApplicationJob
  self.queue_adapter = :resque
  
  queue_as :video

  #
  # ジョブを実行する
  #
  # @param archive [Archive]
  def perform(archive)
    archive.update_video()
  end
end
