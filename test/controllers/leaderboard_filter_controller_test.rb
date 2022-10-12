require 'test_helper'

class LeaderboardFilterControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/leaderboards/filter"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_redirect_if_no_leaderboard
    get "/leaderboards/filter/results"
    assert_response :redirect

    get("/leaderboards/filter/results", params: {leaderboard: nil})
    assert_response :redirect
  end

  def test_get_selected_params
    get("/leaderboards/filter/results", params: {class: "paladin", leaderboard: "2v2", region: "EU"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil assigns(:selected)[:class]
    assert_not_nil assigns(:selected)[:leaderboard]
    assert_not_nil assigns(:selected)[:region]
  end

  def test_find_filtered_results
    base_params = {class: "paladin", leaderboard: "2v2", region: "US"}
    test_params = [
      base_params,
      base_params.merge({factions: "alliance"}),
      base_params.merge({races: "human"}),
      base_params.merge({realm: "realm0"}),
    ]

    test_params.each do |params|
      get("/leaderboards/filter/results", params: params)

      assert_response :success
      assert_not_nil assigns(:leaderboard)
      assert_not_empty assigns(:leaderboard)
      assert_not_equal(0, @controller.instance_variable_get(:@leaderboard).size, "No players returned for #{params}")
    end
  end

  def test_not_include_on_partial_race_match
    base_params = {class: "druid", leaderboard: "3v3", region: "US"}
    troll_params = base_params.merge({races: "troll"})
    zandalari_troll_params = base_params.merge({races: "zandalari-troll"})

    get("/leaderboards/filter/results", params: troll_params)
    troll = @controller.instance_variable_get(:@leaderboard)
    troll.each do | player |
      assert_equal("Troll", player.race)
    end

    get("/leaderboards/filter/results", params: zandalari_troll_params)
    zandalari = @controller.instance_variable_get(:@leaderboard)
    zandalari.each do | player |
      assert_equal("Zandalari Troll", player.race)
    end
  end
end
