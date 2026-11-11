module DoorCheck
  class BackupCodesController < ApplicationController
    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:backup_codes) }
    include ExistingSecondStep

    def create
      @codes = BackupCodes.create_for(door_check_person)
      render :show
    end
  end
end
