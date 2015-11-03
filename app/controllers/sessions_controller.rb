class SessionsController < ApplicationController
  def new
    #title "Login"
  end

  def create
    user = User.login(params[:session][:username],params[:session][:password])
    if user
      # Log the user in and redirect to the user's show page.
      flash.discard(:error) # discard previous errors with a successful login
      session[:user_id] = user.id
      session[:user_generation] = user.generation
      redirect_to root_path
    else
      # Create an error message.
      flash[:error] = "We could not log you in with that username and password."
      redirect_to :action => 'new'
    end
  end

  def destroy
    reset_session
    cookies.delete :last_char_id
    redirect_to :action => 'new'

  end

end