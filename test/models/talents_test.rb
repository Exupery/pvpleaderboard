require "test_helper"

class TalentsTest < ActiveSupport::TestCase
  test "should get talents for each class" do
    (1..12).each do |id|
      assert_not_nil(Talents.get_talents(id, 0))
    end
  end
end
