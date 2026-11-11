module DoorCheck
  class BackupCodesController < ApplicationController
    def create
      @codes = BackupCodes.create_for(door_check_person)
      render :show
    end
  end
end
