require "test_helper"

class OverviewControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :overview
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show overview" do
    ["2v2", "3v3", "5v5", "rbg", "all"].each do |bracket|
      get(:overview, {"bracket" => bracket})
      assert_response :success

      assert_not_nil assigns(:factions)
      assert_not_nil assigns(:races)
      assert_not_nil assigns(:classes)
      assert_not_nil assigns(:specs)
      assert_not_nil assigns(:realms)
      assert_not_nil assigns(:guilds)
      assert_not_nil assigns(:bracket)

      assert_not_empty assigns(:factions)
      assert_not_empty assigns(:races)
      assert_not_empty assigns(:classes)
      assert_not_empty assigns(:specs)
      assert_not_empty assigns(:realms)
      assert_not_empty assigns(:guilds)
      assert_not_empty assigns(:bracket)
    end
  end
end
