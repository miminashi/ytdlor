class ThumbnailDownloadJob < ApplicationJob
  queue_as :thumbnail

  #
  # ジョブを実行する
  #
  # @param archive [Archive]
  def perform(archive_id)
    archive = Archive.find(archive_id)
    archive.update_title()
    archive.update_thumbnail()
  end
end
