require "test_helper"

class RacecsTest < ActiveSupport::TestCase
  test "should get a list of races" do
    assert_not_nil Races.list
    assert_not_empty Races.list
  end

  test "should get a list of distinct race names" do
    assert_not_nil Races.names
    assert_not_empty Races.names
    assert_equal(Races.names.size, Races.names.uniq.size)
  end
end
