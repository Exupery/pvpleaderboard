require "test_helper"

class TalentsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :talents_by_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show talents by class" do
    get(:talents_by_class, {"class" => "druid", "spec" => "spec10"})
    assert_response :success

    assert_not_nil assigns(:class_slug)
    assert_not_nil assigns(:spec_slug)
    assert_not_nil assigns(:counts)
    assert_not_nil assigns(:total)
    assert_not_nil assigns(:class_talents)

    assert_not_empty :counts
    assert_not_empty :class_talents

    assert_not_equal(0, :total)
  end
end
