require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :index
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end
