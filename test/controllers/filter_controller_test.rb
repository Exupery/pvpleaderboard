require "test_helper"

class FilterControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :filter
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should redirect if no class or spec" do
    get :results
    assert_response :redirect

    get(:results, params: {class: "death-knight"})
    assert_response :redirect

    get(:results, params: {spec: "frost"})
    assert_response :redirect
  end

  test "should get selected params" do
    get(:results, params: {class: "death-knight", spec: "frost"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil  assigns(:selected)[:class]
  end

  test "should find filtered results" do
    base_params = {class: "death-knight", spec: "frost"}
    test_params = [
      base_params,
      base_params.merge({factions: "alliance"}),
      base_params.merge({races: "tauren"}),
      base_params.merge({realm: "realm0"}),
      base_params.merge({leaderboards: "3v3"}),
      base_params.merge({regions: "EU"}),
      base_params.merge({"cr-bracket": "2v2", "current-rating": 2000}),
    ]

    test_params.each do |params|
      get(:results, params: params)

      assert_response :success
      assert_not_nil assigns(:class_id)
      assert_not_nil assigns(:talent_counts)
      assert_not_empty assigns(:talent_counts)
      assert_not_nil assigns(:stat_counts)
      assert_not_nil assigns(:gear)
      assert_not_nil assigns(:total)
      assert_not_equal(0, @controller.instance_variable_get(:@total), "No players returned for #{params}")
    end
  end
end
