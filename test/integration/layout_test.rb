require "test_helper"

class LayoutTest < ActionDispatch::IntegrationTest
  test "a door_check page loads the host's application stylesheet" do
    get "/door_check/email_sign_in/new"

    assert_select "head link[rel=stylesheet][href^='/assets/application-']"
  end
end
