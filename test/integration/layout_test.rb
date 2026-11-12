require "test_helper"

class LayoutTest < ActionDispatch::IntegrationTest
  test "a door_check page loads the host's application stylesheet" do
    get "/door_check/email_sign_in/new"

    assert_select "head link[rel=stylesheet][href^='/assets/application-']"
  end

  test "a door_check page loads the stylesheet the host names in door_check's configuration" do
    DoorCheck.configuration.stylesheet = "door_check/application"
    get "/door_check/email_sign_in/new"

    assert_select "head link[rel=stylesheet][href^='/assets/door_check/application-']"
  ensure
    DoorCheck.configuration.stylesheet = "application"
  end
end
