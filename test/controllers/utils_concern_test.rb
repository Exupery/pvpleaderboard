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
    assert_not_empty last_players_update
    assert_not_equal("UNKNOWN", last_players_update)
    assert_kind_of(DateTime, DateTime.strptime(last_players_update, "%d %b %Y %H:%M:%S"))
  end
end
