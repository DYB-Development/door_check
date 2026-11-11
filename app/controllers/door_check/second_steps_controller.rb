module DoorCheck
  class SecondStepsController < ApplicationController
    def new
    end

    def create
      method_name = DoorCheck.configuration.authenticator.verify(door_check_person, params[:code].to_s.strip)
      door_check_session.prove!(method_name)
      redirect_to session.delete(EntryCheck::RETURN_KEY) || "/"
    end
  end
end
