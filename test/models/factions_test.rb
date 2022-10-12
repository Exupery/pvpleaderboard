require "test_helper"

class FactionsTest < ActiveSupport::TestCase
  def test_get_a_list_of_factions
    assert_not_nil Factions.list
    assert_not_empty Factions.list
  end
end
