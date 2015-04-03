require "test_helper"

class TalentsTest < ActiveSupport::TestCase
  test "should get talents for each class" do
    (1..11).each do |id|
      assert_not_nil(Talents.get_talents id)
      assert_not_empty(Talents.get_talents id)
    end
  end
end
