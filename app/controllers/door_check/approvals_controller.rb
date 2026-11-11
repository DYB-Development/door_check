module DoorCheck
  class ApprovalsController < ApplicationController
    def index
      @person = door_check_person
    end
  end
end
