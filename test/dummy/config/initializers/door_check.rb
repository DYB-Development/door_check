DoorCheck.configure do |config|
  config.offered_methods = %i[password authenticator_app]
  config.person_method = :current_user
  config.account_method = :current_account
  config.existing_authenticator = "StoredAuthenticator"
  config.person_accounts = ->(_user) { Account.all }
end
