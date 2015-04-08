require "test_helper"

class ClassesControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :select_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should redirect if invalid class or spec" do
    get(:results_by_class, {"class" => "murloc", "spec" => "spec13"})
    assert_response :redirect

    get(:results_by_class, {"class" => "hunter", "spec" => "pirate"})
    assert_response :redirect
  end

  test "should find results" do
    get(:results_by_class, {"class" => "hunter", "spec" => "spec13"})
    assert_response :success

    assert_not_nil assigns(:class_id)
    assert_not_nil assigns(:spec_id)
    assert_not_nil assigns(:total)
    assert_not_nil assigns(:talent_counts)
    assert_not_nil assigns(:major_glyph_counts)
    assert_not_nil assigns(:minor_glyph_counts)
    assert_not_nil assigns(:stat_counts)

    assert_not_empty :talent_counts
    assert_not_empty :major_glyph_counts
    assert_not_empty :stat_counts
  end
end
