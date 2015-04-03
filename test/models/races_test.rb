require "test_helper"

class RacecsTest < ActiveSupport::TestCase
  test "should get a list of races" do
    assert_not_nil Races.list
    assert_not_empty Races.list
  end
end
