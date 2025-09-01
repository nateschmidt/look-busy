require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get weekly" do
    get dashboard_weekly_url
    assert_response :success
  end
end
