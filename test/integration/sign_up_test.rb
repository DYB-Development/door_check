require "test_helper"

class SignUpTest < ActionDispatch::IntegrationTest
  test "a visitor opens the sign-up page and is asked for their name" do
    get "/door_check/sign_up/new"

    assert_select "form[action='/door_check/sign_up'] input[name=name]"
  end

  test "the sign-up page is not found when the host has set no sign-up callable" do
    sign_up_person = DoorCheck.configuration.sign_up_person
    DoorCheck.configuration.sign_up_person = nil

    get "/door_check/sign_up/new"

    assert_response :not_found
  ensure
    DoorCheck.configuration.sign_up_person = sign_up_person
  end

  test "the sign-up page is not found when the host does not offer email codes" do
    offered = DoorCheck.configuration.offered_methods
    DoorCheck.configuration.offered_methods = %i[password email_link]

    get "/door_check/sign_up/new"

    assert_response :not_found
  ensure
    DoorCheck.configuration.offered_methods = offered
  end
end
