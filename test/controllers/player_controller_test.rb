require 'test_helper'

class PlayerControllerTest < ActionDispatch::IntegrationTest
  def test_set_title_and_description
    get "/players"
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end