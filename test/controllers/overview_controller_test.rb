require "test_helper"

class OverviewControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :stats
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show overview" do
    ["2v2", "3v3", "5v5", "rbg", "all"].each do |bracket|
      get(:stats, {"bracket" => bracket})
      assert_response :success if bracket != "all"
      assert_response :redirect if bracket == "all"

      assert_not_nil assigns(:factions)
      assert_not_nil assigns(:races)
      assert_not_nil assigns(:classes)
      assert_not_nil assigns(:specs)
      assert_not_nil assigns(:bracket)

      assert_not_empty :factions
      assert_not_empty :class_talents
      assert_not_empty :races
      assert_not_empty :specs
      assert_not_empty :bracket
    end
  end
end
