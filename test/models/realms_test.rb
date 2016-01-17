require "test_helper"

class RealmsTest < ActiveSupport::TestCase
  test "should get a list of realms" do
    assert_not_nil Realms.list
    assert_not_empty Realms.list
  end
end
