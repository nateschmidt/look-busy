require "test_helper"

class RecurringMeetingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get recurring_meetings_index_url
    assert_response :success
  end

  test "should get show" do
    get recurring_meetings_show_url
    assert_response :success
  end

  test "should get new" do
    get recurring_meetings_new_url
    assert_response :success
  end

  test "should get create" do
    get recurring_meetings_create_url
    assert_response :success
  end

  test "should get edit" do
    get recurring_meetings_edit_url
    assert_response :success
  end

  test "should get update" do
    get recurring_meetings_update_url
    assert_response :success
  end

  test "should get destroy" do
    get recurring_meetings_destroy_url
    assert_response :success
  end
end
