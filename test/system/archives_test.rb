require "application_system_test_case"

class ArchivesTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  BIG_BUCK_BUNNY_URL = "https://vimeo.com/1084537"
  ELEPHANTS_DREAM_URL = "https://vimeo.com/1132937"

  setup do
    perform_enqueued_jobs do
      Archive.create(:original_url => BIG_BUCK_BUNNY_URL)
    end

    @archive = Archive.ordered.first
  end

  test "ビデオアーカイブの表示" do
    visit archives_path
    click_link "Big Buck Bunny"

    assert_selector "h2", text: "Big Buck Bunny"
  end

  test "ビデオアーカイブの追加" do
    visit archives_path
    assert_selector "h1", text: "保存したビデオ"

    click_on "動画を追加する"
    fill_in "動画のURL", with: ELEPHANTS_DREAM_URL

    assert_selector "h1", text: "保存したビデオ"
    click_on "動画を追加"

    perform_enqueued_jobs

    assert_selector "h1", text: "保存したビデオ"
    assert_text "Elephants Dream"
  end
end
