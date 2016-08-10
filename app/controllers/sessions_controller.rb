class SessionsController < ApplicationController
	before_action :authenticate_user!
  def create
    cookies.signed[:user_id] = current_user.id
    redirect_to messages_path
  end
end