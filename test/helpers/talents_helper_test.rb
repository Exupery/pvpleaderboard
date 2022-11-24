require "test_helper"

class TalentsHelperTest < ActionView::TestCase
  @@test_talents = {
    111 => { :row => 1, :col => 8 },
    222 => { :row => 2, :col => 7 },
    333 => { :row => 3, :col => 6 },
    444 => { :row => 4, :col => 5 }
  }

  def test_find_min_row
    actual = find_min_row @@test_talents
    assert actual == 1
  end

  def test_find_max_row
    actual = find_max_row @@test_talents
    assert actual == 4
  end

  def test_find_min_col
    actual = find_min_col @@test_talents
    assert actual == 5
  end

  def test_find_max_col
    actual = find_max_col @@test_talents
    assert actual == 8
  end
end
