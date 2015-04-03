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
    assert_not_equal(0, total_player_count(1, 0))
    assert_equal(0, total_player_count(-999, -999))
  end
end