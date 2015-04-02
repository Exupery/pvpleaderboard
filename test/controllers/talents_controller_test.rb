require "test_helper"

class TalentsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :talents_by_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end
