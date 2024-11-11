require "application_system_test_case"

class ArchivesTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  BIG_BUCK_BUNNY_URL = "https://www.youtube.com/watch?v=YE7VzlLtp-4"
  ELEPHANTS_DREAM_URL = "https://www.youtube.com/watch?v=TLkA0RELQ1g"
  VIDEO_1 = "https://x.com/miminashi/status/1330543926416171010"
  VIDEO_2 = "https://drive.google.com/file/d/1IbayJypLM7nmqUQlqIMlCTeJG3nGW58P/view"

  setup do
    perform_enqueued_jobs do
      Archive.create(:original_url => VIDEO_1)
    end

    @archive = Archive.ordered.first
  end

  test "ビデオアーカイブの表示" do
    visit archives_path
    click_link "Миминаши - フィラメントの乾燥これでやってる（USB接続の温度計とSSRとドライヤーで50℃を保ってる）"

    assert_selector "h2", text: "Миминаши - フィラメントの乾燥これでやってる（USB接続の温度計とSSRとドライヤーで50℃を保ってる）"
  end

  test "ビデオアーカイブの追加" do
    visit archives_path
    assert_selector "h1", text: "保存したビデオ"

    click_on "動画を追加する"
    fill_in "動画のURL", with: VIDEO_2

    assert_selector "h1", text: "保存したビデオ"
    click_on "動画を追加"

    perform_enqueued_jobs

    assert_selector "h1", text: "保存したビデオ"
    assert_text "test_10s.mov"
  end
end
