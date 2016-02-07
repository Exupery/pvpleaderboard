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

  test "should show details for a realm" do
    ["2v2", "3v3", "5v5", "rbg", "all"].each do |bracket|
      get(:details, {"bracket" => bracket, "realm_slug" => "realm0"})
      assert_response :success

      assert_not_nil assigns(:realm_name)
      assert_not_nil assigns(:realm_slug)
    end
  end

  test "should redirect if invalid realm" do
    get(:details, {"bracket" => "3v3", "realm_slug" => "NOT_A_VALID_REALM"})
    assert_response :redirect
  end
end
