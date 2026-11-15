module DoorCheck
  class SignUpsController < ApplicationController
    before_action { head :not_found unless DoorCheck.configuration.sign_up_person }

    def new
    end
  end
end
