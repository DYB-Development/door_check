module DoorCheck
  class ApprovalRequestsController < ApplicationController
    REQUEST_KEY = :door_check_approval_request_id

    def create
      person = DoorCheck.configuration.find_person_by_email.call(params[:email].to_s.strip)
      challenge = Challenge.request_approval(person, device: request.user_agent.to_s.truncate(255), ip_address: request.remote_ip)
      session[REQUEST_KEY] = challenge.id
      redirect_to door_check.approval_request_path
    end

    def show
      @challenge = Challenge.find_by(id: session[REQUEST_KEY])
    end
  end
end
