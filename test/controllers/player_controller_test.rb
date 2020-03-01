require 'test_helper'

class PlayerControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :search
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end