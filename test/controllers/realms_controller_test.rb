require 'test_helper'

class RealmsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :show
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show counts for all realms" do
    ["2v2", "3v3", "rbg", "all"].each do |bracket|
      get(:show, params: {bracket: bracket})
      assert_response :success

      assert_not_nil assigns(:realms)
      assert_not_empty assigns(:realms)
      assert_nil assigns(:region)
      assert_nil assigns(:region_clause)
    end
  end

  test "should show counts for all regions" do
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg", "all"].each do |bracket|
        get(:show, params: {bracket: bracket, region: region})
        assert_response :success

        assert_not_nil assigns(:realms)
        assert_not_empty assigns(:realms)
        assert_not_nil assigns(:region)
        assert_not_nil assigns(:region_clause)
      end
    end
  end

  test "should show details for a realm" do
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg"].each do |bracket|
        get(:details, params: {bracket: bracket, region: region, realm_slug: "realm0"})
        assert_response :success

        assert_not_nil assigns(:realm)
      end
    end
  end

  test "should redirect if invalid realm" do
    get(:details, params: {bracket: "3v3", region: "us", realm_slug: "NOT_A_VALID_REALM"})
    assert_response :redirect
  end
end
