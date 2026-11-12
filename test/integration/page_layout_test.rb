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

  test "a visitor who chose dark mode sees a door_check page in dark mode" do
    cookies[:keystone_theme] = "dark"

    get "/door_check/email_sign_in/new"

    assert_select "html[data-theme=dark]"
  end
end
