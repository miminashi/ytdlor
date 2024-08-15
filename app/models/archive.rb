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

  has_one_attached :thumbnail do |attachable|
    attachable.variant(:thumbnail, resize_to_limit: [640, 360])
  end
  has_one_attached :video
  has_one_attached :video_download_log

  attribute(:status, default: Status::WAITING)

  # バリデーション
  validates(:original_url, presence: true)
  validates(:status, presence: true, inclusion: {
    :in => [
      Status::WAITING,
      Status::DONE,
      Status::PROCESSING,
      Status::FAILED
    ]
  })

  # scope
  scope :ordered, -> { order({:id => :desc}) }
  scope :failed, -> { where({:status => Status::FAILED}) }

  # コールバック
  before_save do
    # 仮のタイトルを設定する
    unless self.title
      self.title = self.default_title
    end

    # サムネイルとビデオが存在するならステータスを完了にする
    if self.thumbnail.attached? and self.video.attached?
      self.status = Status::DONE
    end
  end

  broadcasts_to ->(archive) { TURBO_CHANNEL }, inserts_by: :prepend

  after_commit :after_create_commit, on: :create


  def update_thumbnail_later
    ThumbnailDownloadJob.perform_later(self.id)
  end

  def update_video_later
    VideosDownloadJob.perform_later(self.id)
  end

  def waiting?
    status == Status::WAITING
  end

  def done?
    status == Status::DONE
  end

  def video_download_log_text
    video_download_log.blob.open do |f|
      f.read
    end
  end

  #
  # 動画のタイトルを取得してtitleに設定する
  #
  #   note:
  #     - 異常系が全然考慮されてないのでなんとかする
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

    logger.info("サムネイルの更新が完了しました")

    return true
  end

  # ビデオを取得する
  def update_video
    self.reload
    self.update({:status => Status::PROCESSING})
    Dir.mktmpdir do |dir|
      filename = File.join(dir, 'download.mp4')
      log_filename = File.join(dir, 'download.log')
      command = 'yt-dlp --newline -f "bestvideo[ext=mp4]+bestaudio[ext=aac]/best[ext=mp4]" -o "%s" "%s"' % [filename, self.original_url]
      success = nil
      Open3.popen2e(command) do |stdin, stdoe, wait_thr|
        log = File.open(log_filename, 'w')
        while (line = stdoe.gets) do
          # youtube-dl の [download] ではじまる行は間引きする
          if line =~ /[download]/
            logger.info(line.chomp) if line =~ /\d{1,3}.0%/
          else
            logger.info(line.chomp)
          end
          log.write(line)
        end
        log.close
        success = wait_thr.value.success?
      end
      self.reload
      if success
        self.video.attach(io: File.open(filename), filename: filename, content_type: 'video/mp4')
        logger.info("ビデオのダウンロードに成功しました")
      else
        self.update({:status => Status::FAILED})
        logger.info("ビデオのダウンロードに失敗しました")
      end
      self.video_download_log.attach(io: File.open(log_filename), filename: 'download.log', content_type: 'text/plain')
      broadcast_replace_to(TURBO_CHANNEL)
    end
  end


  # このへんは本来は別クラスに置いたほうがいいかも

  # タイトルを取得する
  def fetch_title(video_url)
    command = 'yt-dlp -e "%s"' % video_url
    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      logger.info("タイトルの取得に成功しました")
      return stdout.chomp
    else
      logger.debug stderr
      logger.debug("タイトルの取得に失敗しました")
      return nil
    end
  end

  # サムネイルのURLを取得する
  def fetch_thumbnail_url(video_url)
    command = 'yt-dlp --get-thumbnail "%s"' % original_url
    stdout, stderr, status = Open3.capture3(command)
    if status.success?
      logger.info("サムネイルURLの取得に成功しました")
      return stdout.chomp
    else
      logger.debug stderr
      logger.info("サムネイルURLの取得に失敗しました")
      return nil
    end
  end

  private

  def default_title
    m_count = Archive.where('title like ?', '新しい動画%').count
    if m_count > 0
      return '新しい動画(%s)' % m_count
    else
      return '新しい動画'
    end
  end

  def after_create_commit
    self.update_thumbnail_later
    self.update_video_later
  end
end
