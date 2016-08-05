class SessionsController < ApplicationController
	before_action :authenticate_user!
  def create
    cookies.signed[:username] = current_user.name
    redirect_to messages_path
  end
end