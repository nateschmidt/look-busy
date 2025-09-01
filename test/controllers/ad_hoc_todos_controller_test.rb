require "test_helper"

class AdHocTodosControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get ad_hoc_todos_create_url
    assert_response :success
  end

  test "should get destroy" do
    get ad_hoc_todos_destroy_url
    assert_response :success
  end
end
