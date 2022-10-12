require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  def test_index
    get "/"
    assert_equal 200, status
    assert_not_nil assigns(:description)
  end
end
