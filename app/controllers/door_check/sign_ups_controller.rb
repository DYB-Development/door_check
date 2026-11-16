module DoorCheck
  class SignUpsController < ApplicationController
    include SendSignInCode

    SIGN_IN_METHOD_LABELS = { email_code: "Emailed code", password: "Password" }.freeze

    before_action { head :not_found unless DoorCheck.configuration.sign_up_offered? }
    helper_method :sign_in_method_tabs, :chosen_sign_in_method

    def new
    end

    def create
      return refuse_sign_up("Tick the agreement to sign up.") unless params[:agreement] == "1"
      return refuse_sign_up("Enter a password to sign up.") if chosen_sign_in_method == :password && params[:password].blank?

      email = params[:email].to_s.strip
      return redirect_to(door_check.new_email_code_path) if find_person(email)

      result = DoorCheck.configuration.sign_up_person.call(self, submitted_values)
      return refuse_sign_up(result.message) unless result.ok?

      return sign_in_with_password(email) if chosen_sign_in_method == :password

      door_check_send_sign_in_code(find_person(email), email)
      redirect_to door_check.new_email_code_path
    end

    private

    def chosen_sign_in_method
      sign_in_methods.find { |method_name| method_name.to_s == params[:sign_in_method] } || sign_in_methods.first
    end

    def sign_in_method_tabs
      sign_in_methods.map do |method_name|
        { label: SIGN_IN_METHOD_LABELS.fetch(method_name), href: door_check.new_sign_up_path(request.query_parameters.merge(sign_in_method: method_name)),
          current: method_name == chosen_sign_in_method }
      end
    end

    def refuse_sign_up(message)
      @error = message
      render :new, status: :unprocessable_content
    end

    def submitted_values
      params.to_unsafe_h.except(:controller, :action, :authenticity_token)
    end

    def find_person(email)
      DoorCheck.configuration.find_person_by_email.call(email)
    end

    def sign_in_with_password(email)
      person = find_person(email)
      DoorCheck.configuration.sign_in_person.call(self, person)
      door_check_signed_in(person, method_name: :password)
      EmailConfirmation.for(person).update!(email: email)
      SignInMailer.confirmation(Challenge.issue_confirmation(person, email)).deliver_now
      redirect_to "/"
    end

    def sign_in_methods
      DoorCheck.configuration.sign_up_methods
    end
  end
end
