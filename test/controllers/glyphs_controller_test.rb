require "test_helper"

class GlyphsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :glyphs_by_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end
end
