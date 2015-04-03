require "test_helper"

class SpecsTest < ActiveSupport::TestCase
  test "should get a list of specs" do
    assert_not_nil Specs.list
    assert_not_empty Specs.list
  end

  test "should get slugs for all specs" do
    assert_not_nil Specs.slugs
    assert_not_empty Specs.slugs
  end
end
