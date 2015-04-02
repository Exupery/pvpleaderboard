require "test_helper"

class OverviewControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :stats
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end
