class SessionsController < ApplicationController
  def callback

    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(["provider"].auth["uid"])

    if user
     session[:user_id] = user.id
     redirect_to root_url, :notice => "Login Success."
    else
     User.create_with_omniauth(auth)
     redirect_to root_url, :notice => "#{auth["info"]["name"]}s #{auth["provider"]} account connected"
    end
  end

  def destroy
   session[:user_id] = nil
   redirect_to root_url, :notice => "Logout"
  end
end
