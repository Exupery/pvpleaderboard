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

    get(:results, {"class" => "death-knight"})
    assert_response :redirect

    get(:results, {"spec" => "frost"})
    assert_response :redirect
  end

  test "should get selected params" do
    get(:results, {"class" => "death-knight", "spec" => "frost"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty assigns(:selected)
    assert_not_nil  assigns(:selected)[:class]
  end

  test "should find filtered results" do
    get(:results, {"class" => "death-knight", "spec" => "frost"})
    assert_response :success
    assert_not_nil assigns(:class_id)
    assert_not_nil assigns(:talent_counts)
  end
end
