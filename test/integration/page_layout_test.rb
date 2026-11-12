require "test_helper"

class PageLayoutTest < ActionDispatch::IntegrationTest
  test "a door_check page loads the host's application stylesheet" do
    get "/door_check/email_sign_in/new"

    assert_select "head link[rel=stylesheet][href^='/assets/application']"
  end

  test "a door_check page loads the stylesheet the host names instead" do
    DoorCheck.configuration.stylesheet = "brand"

    get "/door_check/email_sign_in/new"

    assert_select "head link[rel=stylesheet][href^='/assets/brand']"
  ensure
    DoorCheck.configuration.stylesheet = "application"
  end
end
