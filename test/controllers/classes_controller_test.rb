require "test_helper"

class ClassesControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/pvp/warlock"
    assert_equal 200, status
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  def test_redirect_if_invalid_class
    get "/pvp/murloc/affliction"
    assert_response :redirect
  end

  def test_redirect_if_invalid_spec
    get "/pvp/rogue/pirate"
    assert_response :redirect
  end

  def test_find_results
    get "/pvp/hunter/beast-mastery"
    assert_response :success

    assert_not_nil assigns(:class_id)
    assert_not_nil assigns(:spec_id)
    assert_not_nil assigns(:total)
    assert_not_nil assigns(:talent_counts)
    assert_not_nil assigns(:stat_counts)
    assert_not_nil assigns(:gear)

    assert_not_empty assigns(:talent_counts)
    assert_not_empty assigns(:stat_counts)
    assert_not_empty assigns(:gear)
  end
end
