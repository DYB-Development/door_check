DoorCheck.configure do |config|
  config.offered_methods = %i[password authenticator_app backup_codes passkey trusted_device device_approval email_code email_link]
  config.person_method = :current_user
  config.account_method = :current_account
  config.existing_authenticator = "StoredAuthenticator"
  config.person_accounts = ->(_user) { Account.all }
  config.find_person_by_email = ->(email) { User.find_by(email: email) }
  config.sign_in_person = ->(controller, user) { controller.session[:user_id] = user.id }
  config.sign_out_person = ->(controller) { controller.session.delete(:user_id) }
  config.sign_up_agreement_label = "I agree to the Terms of Service and Privacy Policy"
  config.sign_up_agreement_links = lambda do |_controller|
    [ { title: "Terms of Service", url: "/terms" }, { title: "Privacy Policy", url: "/privacy" } ]
  end
  config.sign_up_person = lambda do |_controller, values|
    if values[:sign_in_method] == "password" && values[:password].to_s.length < 12
      next DoorCheck::Result.new(ok: false, message: "Choose a password of at least 12 characters.")
    end

    User.create!(email: values[:email])
    DoorCheck::Result.new(ok: true)
  end
  config.email_change_confirmed = lambda do |_controller, user, email|
    user.update!(email: email)
    DoorCheck::Result.new(ok: true)
  end
  config.email_change_cancelled = ->(_controller, _user, _email) { DoorCheck::Result.new(ok: true) }
end
