require "test_helper"

class GlyphsControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :glyphs_by_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should show glyphs by class" do
    get(:glyphs_by_class, {"class" => "warlock", "spec" => "spec8"})
    assert_response :success

    assert_not_nil assigns(:class_slug)
    assert_not_nil assigns(:spec_slug)
    assert_not_nil assigns(:major_counts)
    assert_not_nil assigns(:total)
    assert_not_nil assigns(:class_glyphs)

    assert_not_empty :major_counts
    assert_not_empty :class_glyphs

    assert_not_equal(0, :total)
  end
end
