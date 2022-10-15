require 'test_helper'

class RealmsControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/realms"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_show_counts_for_all_realms
    ["2v2", "3v3", "rbg", "all"].each do |bracket|
      get("/realms", params: {bracket: bracket})
      assert_response :success

      assert_not_nil assigns(:realms)
      assert_not_empty assigns(:realms)
      assert_nil assigns(:region)
      assert_nil assigns(:region_clause)
    end
  end

  def test_show_counts_for_all_regions
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg", "all"].each do |bracket|
        get("/realms", params: {bracket: bracket, region: region})
        assert_response :success

        assert_not_nil assigns(:realms)
        assert_not_empty assigns(:realms)
        assert_not_nil assigns(:region)
        assert_not_nil assigns(:region_clause)
      end
    end
  end

  def test_show_details_for_a_realm
    Regions.list.each do |region|
      ["2v2", "3v3", "rbg"].each do |bracket|
        get "/realms/#{bracket}/#{region}/realm0"
        assert_response :success

        assert_not_nil assigns(:realm)
      end
    end
  end

  def test_redirect_if_invalid_bracket
    get "/realms/NOT_A_VALID_BRACKET/us/tichondrius"
    assert_response :redirect
  end

  def test_redirect_if_invalid_realm
    get "/realms/3v3/us/NOT_A_VALID_REALM"
    assert_response :redirect
  end

  def test_redirect_old_realm_detail_path
    get("/realms", params: {bracket: "realm0", region: "3v3"})
    assert_response :redirect
  end
end
