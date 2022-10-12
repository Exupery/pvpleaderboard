require "test_helper"

class ClassesTest < ActiveSupport::TestCase
  def test_get_a_list_of_classes
    assert_not_nil Classes.list
    assert_not_empty Classes.list
  end
end
