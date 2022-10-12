require "test_helper"

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/statistics"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_show_statistics
    ["2v2", "3v3", "rbg", "all"].each do |bracket|
      get("/statistics", params: {bracket: bracket})
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

  def test_show_statistics_for_region
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg", "all"].each do |bracket|
        get("/statistics", params: {bracket: bracket, region: region})
        assert_response :success

        assert_not_nil assigns(:region)
        assert_not_nil assigns(:region_clause)
        assert_not_empty assigns(:region)
      end
    end
  end

  def test_show_statistics_for_all_region
    get("/statistics", params: {bracket: "2v2", region: "All"})

    assert_nil assigns(:region)
    assert_nil assigns(:region_clause)
  end
end
