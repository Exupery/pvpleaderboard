require 'test_helper'

class AchievementsTest < ActiveSupport::TestCase
  def test_init
    achievement = Achievement.new(1, "Foo", "Foo the Bar", "cool_icon_bro")
  end

  def test_seasonal
    seasonal_achievements = Achievement.get_seasonal_achievements
    assert_not_nil seasonal_achievements
    assert_not seasonal_achievements.empty?
  end

  def test_by_id
    achievements = Achievement.get_achievements [ 42, 47 ]
    assert_not_nil achievements
    assert achievements.length == 2
  end
end