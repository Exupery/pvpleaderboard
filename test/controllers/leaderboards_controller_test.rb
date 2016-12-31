require "test_helper"

class LeaderboardsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :show
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show leaderboard" do
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg"].each do |bracket|
        get(:show, params: {bracket: bracket, region: region})
        assert_response :success

        assert_not_nil assigns(:bracket)
        assert_not_nil assigns(:active_bracket)
        assert_not_nil assigns(:leaderboard)
        assert_not_nil assigns(:last)
        assert_not_nil assigns(:total)
        assert_not_nil assigns(:region)

        assert_not_empty assigns(:bracket)
        assert_not_empty assigns(:active_bracket)
        assert_not_empty assigns(:leaderboard)
        assert assigns(:last) > 0
        assert assigns(:total) > 0
      end
    end
  end
end
