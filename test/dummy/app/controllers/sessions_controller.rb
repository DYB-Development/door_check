class SessionsController < ApplicationController
  def create
    user = User.find(params[:user_id])
    session[:user_id] = user.id
    door_check_signed_in(user, method_name: params[:method_name].to_sym)
    head :ok
  end

  def proofs
    render json: door_check_proved_by.map(&:first)
  end
end
