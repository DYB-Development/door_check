module DoorCheck
  class SecondStepsController < ApplicationController
    def new
    end

    def create
      method_name = DoorCheck.configuration.authenticator.verify(door_check_person, params[:code].to_s.strip)
      return refuse_code unless method_name

      door_check_session.prove!(method_name)
      redirect_to session.delete(EntryCheck::RETURN_KEY) || "/"
    end

    private

    def refuse_code
      @error = "That code is not right. Check your authenticator app and try again."
      render :new, status: :unprocessable_content
    end
  end
end
