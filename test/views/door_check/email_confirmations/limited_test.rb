require "test_helper"

module DoorCheck
  class EmailConfirmationLimitedPageTest < ActionView::TestCase
    helper KeystoneUiHelper

    test "the page tells the person to try again later" do
      render template: "door_check/email_confirmations/limited"

      assert_select "[role=alert]", text: /Try again later/
    end
  end
end
