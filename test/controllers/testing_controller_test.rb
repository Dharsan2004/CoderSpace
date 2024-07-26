require "test_helper"

class TestingControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get testing_test_url
    assert_response :success
  end
end
