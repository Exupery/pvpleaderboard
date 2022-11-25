require "test_helper"

class TalentsTest < ActiveSupport::TestCase
  def test_get_talents_for_class
    (1..12).each do |id|
      class_talents = Talents.get_class_talents(id, 62)
      assert_not_nil(class_talents)
      assert_not_empty(class_talents)
    end
  end

  def test_get_talents_for_spec
    (62..66).each do |id|
      spec_talents = Talents.get_spec_talents(id)
      assert_not_nil(spec_talents)
      assert_not_empty(spec_talents)
    end
  end
end
