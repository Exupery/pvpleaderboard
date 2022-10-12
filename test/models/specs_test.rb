require "test_helper"

class SpecsTest < ActiveSupport::TestCase
  def test_get_a_list_of_specs
    assert_not_nil Specs.list
    assert_not_empty Specs.list
  end

  def test_get_slugs_for_all_specs
    assert_not_nil Specs.slugs
    assert_not_empty Specs.slugs
  end
end
