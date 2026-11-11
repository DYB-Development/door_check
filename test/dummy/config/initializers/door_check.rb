DoorCheck.configure do |config|
  config.offered_methods = %i[password authenticator_app]
  config.person_method = :current_user
  config.account_method = :current_account
end
