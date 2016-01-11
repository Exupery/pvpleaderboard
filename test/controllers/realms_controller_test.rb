require 'test_helper'

class RealmsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :show
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show counts for all realms" do
    ["2v2", "3v3", "5v5", "rbg", "all"].each do |bracket|
      get(:show, {"bracket" => bracket})
      assert_response :success

      assert_not_nil assigns(:realms)
      assert_not_empty assigns(:realms)
    end
  end
end
