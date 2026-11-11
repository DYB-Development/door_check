class ApplicationController < ActionController::Base
  include DoorCheck::Tracking
  include DoorCheck::EntryCheck

  before_action :door_check_check_entry

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def current_user
    User.find_by(id: session[:user_id])
  end

  def current_account
    Account.find_by(id: session[:account_id])
  end
end
