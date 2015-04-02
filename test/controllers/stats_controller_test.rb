require "test_helper"

class StatsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :stats_by_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end
