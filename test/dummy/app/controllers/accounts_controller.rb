class AccountsController < ApplicationController
  skip_before_action :door_check_check_entry, only: :switch

  def switch
    session[:account_id] = Account.find(params[:id]).id
    head :ok
  end

  def dashboard
    render plain: "Dashboard for #{current_account.name}"
  end
end
