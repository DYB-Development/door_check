module DoorCheck
  class SignUpsController < ApplicationController
    SIGN_IN_METHOD_LABELS = { email_code: "Emailed code", password: "Password" }.freeze

    before_action { head :not_found unless sign_up_offered? }
    helper_method :sign_in_method_tabs

    def new
    end

    def create
      return refuse_sign_up("Tick the agreement to sign up.") unless params[:agreement] == "1"

      result = DoorCheck.configuration.sign_up_person.call(self, submitted_values)
      return refuse_sign_up(result.message) unless result.ok?

      send_code(params[:email].to_s.strip)
      redirect_to door_check.new_email_code_path
    end

    private

    def sign_in_method_tabs
      sign_in_methods.map do |method_name|
        { label: SIGN_IN_METHOD_LABELS.fetch(method_name), href: door_check.new_sign_up_path(request.query_parameters.merge(sign_in_method: method_name)) }
      end
    end

    def refuse_sign_up(message)
      @error = message
      render :new, status: :unprocessable_content
    end

    def submitted_values
      params.to_unsafe_h.except(:controller, :action, :authenticity_token)
    end

    def send_code(email)
      challenge = Challenge.issue(DoorCheck.configuration.find_person_by_email.call(email))
      SignInMailer.code_and_link(challenge, to: email).deliver_now
      session[EmailSignInsController::CHALLENGE_KEY] = challenge.id
    end

    def sign_up_offered?
      DoorCheck.configuration.sign_up_person && sign_in_methods.any?
    end

    def sign_in_methods
      %i[email_code password] & DoorCheck.configuration.offered_methods
    end
  end
end
