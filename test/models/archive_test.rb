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
require "test_helper"

class ArchiveTest < ActiveSupport::TestCase
  def setup
    @archive = Archive.new(original_url: "https://vimeo.com/1084537")
  end

  test "should be valid" do
    assert @archive.valid?
  end

  test "original_url should be present" do
    @archive.original_url = ""
    assert_not @archive.valid?
  end

  test "should get title" do
    @archive.save!
    @archive.update_title
    assert_equal "Big Buck Bunny", @archive.title
  end

  test "should get thumbnail" do
    # broadcast_replace_to がレンダリングするviewからidが参照されるので, DBに保存しておく
    @archive.save!
    @archive.update_thumbnail
    assert @archive.thumbnail.attached?
  end

  test "should get video" do
    # broadcast_replace_to がレンダリングするviewからidが参照されるので, DBに保存しておく
    @archive.save!
    @archive.update_video
    assert @archive.video.attached?
  end
end
