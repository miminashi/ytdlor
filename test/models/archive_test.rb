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
  # test "the truth" do
  #   assert true
  # end
end
