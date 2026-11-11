DoorCheck.configure do |config|
  config.offered_methods = %i[password authenticator_app backup_codes passkey trusted_device device_approval email_code email_link]
  config.person_method = :current_user
  config.account_method = :current_account
  config.existing_authenticator = "StoredAuthenticator"
  config.person_accounts = ->(_user) { Account.all }
  config.find_person_by_email = ->(email) { User.find_by(email: email) }
  config.sign_in_person = ->(controller, user) { controller.session[:user_id] = user.id }
  config.sign_out_person = ->(controller) { controller.session.delete(:user_id) }
end
