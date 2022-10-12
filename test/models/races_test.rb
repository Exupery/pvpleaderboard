require "test_helper"

class RacecsTest < ActiveSupport::TestCase
  def test_get_a_list_of_races
    assert_not_nil Races.list
    assert_not_empty Races.list
  end

  def test_get_a_list_of_distinct_race_names
    assert_not_nil Races.names
    assert_not_empty Races.names
    assert_equal(Races.names.size, Races.names.uniq.size)
  end
end
