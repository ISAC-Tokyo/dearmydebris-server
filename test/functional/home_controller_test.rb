require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get dearmydebris2d" do
    get :dearmydebris2d
    assert_response :success
  end

  test "should get dearmydebris3d" do
    get :dearmydebris3d
    assert_response :success
  end

end
