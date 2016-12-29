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
      base_params.merge({factions: "horde"}),
      base_params.merge({races: "undead"}),
      base_params.merge({realm: "realm0"}),
      base_params.merge({"cr-bracket": "2v2", "current-rating": 2000}),
      base_params.merge({hks: "4077"}),
    ]

    test_params.each do |params|
      get(:results, params: params)

      assert_response :success
      assert_not_nil assigns(:class_id)
      assert_not_nil assigns(:talent_counts)
    end
  end
end
