require "test_helper"

class StatsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :stats_by_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show stats by class" do
    get(:stats_by_class, {"class" => "warrior", "spec" => "spec0"})
    assert_response :success

    assert_not_nil assigns(:class_slug)
    assert_not_nil assigns(:spec_slug)
    assert_not_nil assigns(:stat_counts)

    assert_not_empty :counts
  end
end
