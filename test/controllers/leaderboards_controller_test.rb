require "test_helper"

class LeaderboardsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :show
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show leaderboard" do
    ["2v2", "3v3", "5v5", "rbg"].each do |bracket|
      get(:show, {"bracket" => bracket})
      assert_response :success

      assert_not_nil assigns(:active_bracket)

      assert_not_empty :active_bracket
    end
  end
end
