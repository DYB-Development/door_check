module DoorCheck
  class SecondStepsController < ApplicationController
    before_action :find_authenticator

    def new
    end

    def create
      method_name = verify_code(params[:code].to_s.strip)
      return refuse_code unless method_name

      door_check_session.prove!(method_name)
      redirect_to session.delete(EntryCheck::RETURN_KEY) || "/"
    end

    private

    def find_authenticator
      @person = door_check_person
      @authenticator = DoorCheck.configuration.authenticator
      @second_step_set_up = SecondStep.set_up?(@person)
      @setups = SecondStep.offered_setups(door_check_account)
    end

    def verify_code(code)
      return :authenticator_app if Credential.where(person: @person, method_name: "authenticator_app").any? { |credential| credential.verify(code) }

      @authenticator&.verify(@person, code)
    end

    def refuse_code
      @error = "That code is not right. Check your authenticator app and try again."
      render :new, status: :unprocessable_content
    end
  end
end
