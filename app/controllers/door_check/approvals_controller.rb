module DoorCheck
  class ApprovalsController < ApplicationController
    def index
      @person = door_check_person
    end

    def approve
      waiting_request.approve
      redirect_to door_check.approvals_path
    end

    def decline
      waiting_request.decline
      redirect_to door_check.approvals_path
    end

    private

    def waiting_request = Challenge.awaiting_approval.find_by!(id: params[:id], person: door_check_person)
  end
end
