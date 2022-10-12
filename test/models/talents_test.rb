require "test_helper"

class TalentsTest < ActiveSupport::TestCase
  def test_get_talents_for_each_class
    (1..12).each do |id|
      assert_not_nil(Talents.get_talents(id, 0))
    end
  end
end
