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

  test "a door_check page carries the visitor's keystone_ui mode and look on its root element" do
    KeystoneUi.configuration.register_look("bold", "keystone_ui/looks/bold.css")
    KeystoneUi.configuration.look_supplier = ->(_view) { "bold" }
    cookies[:keystone_theme] = "dark"
    get "/door_check/email_sign_in/new"

    assert_select "html[data-theme=dark][data-look=bold]"
  ensure
    KeystoneUi.configuration.looks.delete("bold")
    KeystoneUi.configuration.look_supplier = nil
  end

  test "a door_check page fits the width of a phone screen" do
    get "/door_check/email_sign_in/new"

    assert_select "head meta[name=viewport][content='width=device-width,initial-scale=1']"
  end
end
