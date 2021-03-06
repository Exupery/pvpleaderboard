require "test_helper"

class ClassesControllerTest < ActionController::TestCase
  test "should set title and description" do
    get :select_class
    assert_response :success
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:description)
  end

  test "should redirect if invalid class or spec" do
    get(:results_by_class, params: {class: "murloc", spec: "spec13"})
    assert_response :redirect

    get(:results_by_class, params: {class: "hunter", spec: "pirate"})
    assert_response :redirect
  end

  test "should find results" do
    get(:results_by_class, params: {class: "hunter", spec: "beast-mastery"})
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
