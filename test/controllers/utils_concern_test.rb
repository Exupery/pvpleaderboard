require "test_helper"
include Utils

class UtilsConcernTest < ActionController::TestCase
  test "should slugify" do
    assert_equal("foo_bar", slugify("FOO bar"))
    assert_equal("foo_bar", slugify("FOO-bar"))
    assert_equal("foo_bar", slugify("FOO_bar"))
    assert_equal("foo_bar_baz_bat", slugify("FOO bar-BAZ_bAt"))
    assert_nil slugify(nil)
  end

  test "should urlify" do
    assert_equal("foo-bar", urlify("FOO bar"))
    assert_equal("foo-bar", urlify("FOO-bar"))
    assert_equal("foo-bar", urlify("FOO_bar"))
    assert_equal("foo-bar-baz-bat", urlify("FOO bar-BAZ_bAt"))
    assert_nil urlify(nil)
  end

  test "should get leaderboard player count" do
    assert_not_equal(0, total_player_count(10, 270))
    assert_equal(0, total_player_count(-999, -999))
  end

  test "should get last updated time" do
    assert_not_nil last_players_update
    assert_kind_of(DateTime, last_players_update)
    assert_not_equal("0", last_players_update.strftime("%Q"))
  end

  test "should remove unused primary stats" do
    high = { :med => 999 }
    low = { :med => 0 }

    agility_highest = { "agility" => high, "intellect" => low, "strength" => low }
    intellect_highest = { "agility" => low, "intellect" => high, "strength" => low }
    strength_highest = { "agility" => low, "intellect" => low, "strength" => high }

    remove_unused_stats agility_highest
    assert agility_highest.has_key? "agility"
    assert_not agility_highest.has_key? "intellect"
    assert_not agility_highest.has_key? "strength"

    remove_unused_stats intellect_highest
    assert intellect_highest.has_key? "intellect"
    assert_not intellect_highest.has_key? "agility"
    assert_not intellect_highest.has_key? "strength"

    remove_unused_stats strength_highest
    assert strength_highest.has_key? "strength"
    assert_not strength_highest.has_key? "agility"
    assert_not strength_highest.has_key? "intellect"
  end
end
