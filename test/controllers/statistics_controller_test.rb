require "test_helper"

class StatisticsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :show
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show statistics" do
    ["2v2", "3v3", "rbg", "all"].each do |bracket|
      get(:show, params: {bracket: bracket})
      assert_response :success

      assert_not_nil assigns(:factions)
      assert_not_nil assigns(:races)
      assert_not_nil assigns(:classes)
      assert_not_nil assigns(:specs)
      assert_not_nil assigns(:realms)
      assert_not_nil assigns(:guilds)
      assert_not_nil assigns(:bracket_fullname)

      assert_not_empty assigns(:factions)
      assert_not_empty assigns(:races)
      assert_not_empty assigns(:classes)
      assert_not_empty assigns(:specs)
      assert_not_empty assigns(:realms)
      assert_not_empty assigns(:guilds)
      assert_not_empty assigns(:bracket_fullname)
    end
  end

  test "should show statistics for region" do
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg", "all"].each do |bracket|
        get(:show, params: {bracket: bracket, region: region})
        assert_response :success

        assert_not_nil assigns(:region)
        assert_not_nil assigns(:region_clause)
        assert_not_empty assigns(:region)
      end
    end
  end

  test "should show statistics for all region" do
    get(:show, params: {bracket: "2v2", region: "All"})

    assert_nil assigns(:region)
    assert_nil assigns(:region_clause)
  end
end
