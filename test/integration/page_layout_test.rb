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

  test "a visitor whose look is chosen sees a door_check page in that look" do
    keystone = KeystoneUi.configuration
    KeystoneUi.reset_configuration!
    KeystoneUi.configuration.register_look :bold, "bold.css"
    KeystoneUi.configuration.look_supplier = ->(_view) { :bold }

    get "/door_check/email_sign_in/new"

    assert_select "html[data-look=bold]"
  ensure
    KeystoneUi.instance_variable_set(:@configuration, keystone)
  end

  test "a door_check page shows no host navigation" do
    get "/door_check/email_sign_in/new"

    assert_select "#host-navigation", count: 0
  end

  test "a door_check page fits the width of a phone screen" do
    get "/door_check/email_sign_in/new"

    assert_select "head meta[name=viewport][content='width=device-width,initial-scale=1']"
  end
end
