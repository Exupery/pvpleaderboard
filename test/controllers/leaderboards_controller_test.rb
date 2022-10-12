require "test_helper"

class LeaderboardsControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/leaderboards/3v3/us"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_show_leaderboard
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg"].each do |bracket|
        get("/leaderboards/#{bracket}/#{region}")
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
