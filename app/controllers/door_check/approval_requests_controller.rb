module DoorCheck
  class ApprovalRequestsController < ApplicationController
    REQUEST_KEY = :door_check_approval_request_id
    NUMBER_KEY = :door_check_approval_number

    before_action { head :not_found unless DoorCheck.configuration.offered_methods.include?(:device_approval) }

    def new
    end

    def create
      person = DoorCheck.configuration.find_person_by_email.call(params[:email].to_s.strip)
      challenge = person && Challenge.request_approval(person, device: request.user_agent.to_s.truncate(255), ip_address: request.remote_ip)
      session[REQUEST_KEY] = challenge&.id
      session[NUMBER_KEY] = challenge&.number || format("%02d", SecureRandom.random_number(10..99))
      redirect_to door_check.approval_request_path
    end

    def show
      @challenge = Challenge.find_by(id: session[REQUEST_KEY])
      @number = session[NUMBER_KEY]
      sign_in_approved if @challenge&.approved? && @challenge.use
    end

    private

    def sign_in_approved
      session.delete(REQUEST_KEY)
      DoorCheck.configuration.sign_in_person.call(self, @challenge.person)
      door_check_signed_in(@challenge.person, method_name: :device_approval)
      redirect_to "/"
    end
  end
end
