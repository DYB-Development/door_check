module DoorCheck
  class SignUpsController < ApplicationController
    before_action { head :not_found unless sign_up_offered? }

    def new
    end

    private

    def sign_up_offered?
      DoorCheck.configuration.sign_up_person && DoorCheck.configuration.offered_methods.include?(:email_code)
    end
  end
end
