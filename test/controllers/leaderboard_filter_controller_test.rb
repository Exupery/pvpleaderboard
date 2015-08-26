require 'test_helper'

class LeaderboardFilterControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :filter
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should redirect if no leaderboard" do
    get :results
    assert_response :redirect

    get(:results, {"leaderboard" => nil})
    assert_response :redirect
  end

  test "should get selected params" do
    get(:results, {"class" => "paladin", "leaderboard" => "2v2"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil  assigns(:selected)[:class]
    assert_not_nil  assigns(:selected)[:leaderboard]
  end

  test "should find filtered results" do
    get(:results, {"class" => "paladin", "leaderboard" => "2v2"})
    assert_response :success
    assert_not_nil assigns(:leaderboard)

    assert_not_empty assigns(:leaderboard)
  end
end
