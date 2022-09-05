require "open3"
require "open-uri"

# == Schema Information
#
# Table name: archives
#
#  id           :integer          not null, primary key
#  title        :string
#  original_url :string
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Archive < ApplicationRecord
  TURBO_CHANNEL = "archives"

  module Status
    WAITING = "waiting"
    DONE = "done"
    PROCESSING = "processing"
    FAILED = "failed"
  end

  has_one_attached :thumbnail
  has_one_attached :video

  attribute(:title, default: "新しい動画")
  attribute(:status, default: Status::WAITING)  # status = {waiting, done}

  # バリデーション
  validates(:original_url, presence: true)

  # scope
  scope :ordered, -> { order({:id => :desc}) }
  scope :failed, -> { where({:status => Status::FAILED}) }

  # コールバック
  after_create do
    ThumbnailDownloadJob.perform_later(self)
    VideosDownloadJob.perform_later(self)
  end

  before_save do
    if self.thumbnail.attached? and self.video.attached?
      self.status = Status::DONE
    end
  end

  broadcasts_to ->(archive) { TURBO_CHANNEL }, inserts_by: :prepend


  def update_thumbnail_later
    ThumbnailDownloadJob.perform_later(self)
  end

  def update_video_later
    VideosDownloadJob.perform_later(self)
  end

  def done?
    status == "done"
  end

  #
  # 動画のタイトルを取得してtitleに設定する
  #
  def update_title
    self.title = fetch_title(self.original_url)
    self.save
  end

  #
  # サムネイルを取得してアタッチする
  #   外部への通信が発生するので同期的に呼び出さないように
  #
  #   note:
  #     強制オプションをつけない限り1回しか実行できないようにしたい
  #
  def update_thumbnail
    thumbnail_url = fetch_thumbnail_url(self.original_url)

    unless thumbnail_url
      return false
    end

    URI.open(thumbnail_url) do |f|
      thumbnail.attach(io: f, filename: 'thumbnail')
    end

    Timeout.timeout(10) do
      until(self.thumbnail.attached?) do
        sleep 1
      end
      broadcast_replace_to(TURBO_CHANNEL)
    end

    puts "サムネイルの更新が完了しました"
  end

  # ビデオを取得する
  def update_video
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'download.mp4')
      # -f bestvideo+bestaudio がpornhubだとうごかない？
      #command = 'youtube-dl --newline -f bestvideo+bestaudio --merge-output-format mp4 -o "%s" "%s"' % [filename, self.original_url]
      command = 'youtube-dl --newline --merge-output-format mp4 -o "%s" "%s"' % [filename, self.original_url]
      #stdout, stderr, status = Open3.capture3(command)
      success = nil
      Open3.popen2e(command) do |stdin, stdoe, wait_thr|
        while (line = stdoe.gets) do
          puts(line.chomp)
        end
        success = wait_thr.value.success?
      end
      if success
        self.video.attach(io: File.open(filename), filename: filename, content_type: 'video/mp4')
        puts("ビデオのダウンロードに成功しました")
        logger.info("ビデオのダウンロードに成功しました")
        broadcast_replace_to(TURBO_CHANNEL)
      else
        #logger.debug stderr
        puts("ビデオのダウンロードに失敗しました")
        return false
      end
    end
  end


  # このへんは本来は別クラスに置いたほうがいいかも

  # タイトルを取得する
  def fetch_title(video_url)
    command = 'youtube-dl -e "%s"' % video_url
    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      return stdout
    else
      logger.debug stderr
      return nil
    end
  end

  # サムネイルのURLを取得する
  def fetch_thumbnail_url(video_url)
    command = 'youtube-dl --get-thumbnail "%s"' % original_url
    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      return stdout.chomp
    else
      logger.debug stderr
      return nil
    end
  end
end
