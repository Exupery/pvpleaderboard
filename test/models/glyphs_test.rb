require "test_helper"

class GlyphsTest < ActiveSupport::TestCase
  test "should get glyphs for each class" do
    (1..11).each do |id|
      assert_not_nil(Glyphs.get_glyphs id)
      assert_not_empty(Glyphs.get_glyphs id)
    end
  end
end
