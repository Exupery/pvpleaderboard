require 'test_helper'

class AchievementsTest < ActiveSupport::TestCase
  def test_init
    achievement = Achievement.new(1, "Foo", "Foo the Bar", "cool_icon_bro")
    assert_not_nil achievement
    assert achievement.icon == "cool_icon_bro"
  end

  def test_init_without_icon
    ## The icon column is NULL for many achievements and was once blank
    [ nil, "" ].each do |missing|
      achievement = Achievement.new(1, "Foo", "Foo the Bar", missing)
      assert achievement.icon == "placeholder"
    end
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