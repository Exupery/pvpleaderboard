require "test_helper"

class FilterControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :filter
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should get selected params" do
    get(:results, {"class" => "death-knight"})
    assert_response :success
    assert_not_nil assigns(:selected)
    assert_not_empty :selected
    assert_not_nil  @controller.instance_variable_get(:@selected)[:class]
  end
end
