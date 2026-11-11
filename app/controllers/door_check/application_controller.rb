module DoorCheck
  class ApplicationController < DoorCheck.configuration.parent_controller.constantize
    helper KeystoneUiHelper

    skip_before_action :door_check_check_entry, raise: false
  end
end
