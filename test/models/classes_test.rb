require "test_helper"

class ClassesTest < ActiveSupport::TestCase
  test "should get a list of classes" do
    assert_not_nil Classes.list
    assert_not_empty Classes.list
  end
end
