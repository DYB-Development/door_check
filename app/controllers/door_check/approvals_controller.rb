module DoorCheck
  class ApprovalsController < ApplicationController
    def index
      @person = door_check_person
    end

    def approve
      Challenge.awaiting_approval.find_by!(id: params[:id], person: door_check_person).approve
      redirect_to door_check.approvals_path
    end
  end
end
