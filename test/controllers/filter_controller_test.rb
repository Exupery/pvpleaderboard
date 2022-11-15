require "test_helper"

class FilterControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/pvp/filter"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_redirect_if_no_class_or_spec
    get "/pvp/filter/results"
    assert_response :redirect

    get("/pvp/filter/results", params: {class: "death-knight"})
    assert_response :redirect

    get("/pvp/filter/results", params: {spec: "frost"})
    assert_response :redirect
  end

  def test_get_selected_params
    get("/pvp/filter/results", params: {class: "death-knight", spec: "frost"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil  assigns(:selected)[:class]
  end

  def test_find_filtered_results
    base_params = {class: "mage", spec: "frost"}
    test_params = [
      base_params,
      base_params.merge({factions: "alliance"}),
      base_params.merge({races: "tauren"}),
      base_params.merge({realm: "realm0"}),
      base_params.merge({leaderboards: "3v3"}),
      base_params.merge({regions: "EU"}),
      base_params.merge({name: "player"}),
      base_params.merge({"cr-bracket": "2v2", "current-rating": 2000}),
      base_params.merge({"active-since": 12}),
      base_params.merge({"arena-achievements": 5341}),
      base_params.merge({"rbg-achievements": "5341-5355"}),
      base_params.merge({"arena-achievements": 5341, "rbg-achievements": "5341-5355"}),
    ]

    test_params.each do |params|
      get("/pvp/filter/results", params: params)

      assert_response :success
      assert_not_equal(0, @controller.instance_variable_get(:@total), "No players returned for #{params}")
      assert_not_nil assigns(:class_id)
      assert_not_nil assigns(:class_talent_counts)
      assert_not_nil assigns(:spec_talent_counts)
      assert_not_nil assigns(:pvp_talent_counts)
      assert_not_nil assigns(:stat_counts)
      assert_not_nil assigns(:gear)
      assert_not_nil assigns(:total)
      assert_not_nil assigns(:players_title)
      assert_not_nil assigns(:top_players)
    end
  end
end
