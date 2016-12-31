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

    get(:results, params: {leaderboard: nil})
    assert_response :redirect
  end

  test "should get selected params" do
    get(:results, params: {class: "paladin", leaderboard: "2v2", region: "EU"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil assigns(:selected)[:class]
    assert_not_nil assigns(:selected)[:leaderboard]
    assert_not_nil assigns(:selected)[:region]
  end

  test "should find filtered results" do
    base_params = {class: "paladin", leaderboard: "2v2", region: "US"}
    test_params = [
      base_params,
      base_params.merge({factions: "alliance"}),
      base_params.merge({races: "human"}),
      base_params.merge({realm: "realm0"}),
      base_params.merge({hks: "4077"}),
    ]

    test_params.each do |params|
      get(:results, params: params)

      assert_response :success
      assert_not_nil assigns(:leaderboard)
      assert_not_empty assigns(:leaderboard)
      assert_not_equal(0, @controller.instance_variable_get(:@leaderboard).size, "No players returned for #{params}")
    end
  end
end
