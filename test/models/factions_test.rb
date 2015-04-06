require "test_helper"

class FactionsTest < ActiveSupport::TestCase
  test "should get a list of factions" do
    assert_not_nil Factions.list
    assert_not_empty Factions.list
  end
end
