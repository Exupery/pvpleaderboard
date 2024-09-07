require "test_helper"

class BlitzControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/leaderboards/blitz/us"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_show_leaderboard
    Regions.list.each do |region|
      get("/leaderboards/blitz/#{region}/monk/mistweaver")
      assert_response :success

      assert_not_nil assigns(:bracket)
      assert_not_nil assigns(:leaderboard)
      assert_not_nil assigns(:last)
      assert_not_nil assigns(:total)
      assert_not_nil assigns(:region)

      assert_not_empty assigns(:leaderboard)
      assert assigns(:bracket) == "blitz_270"
      assert assigns(:last) > 0
      assert assigns(:total) > 0
    end
  end
end
