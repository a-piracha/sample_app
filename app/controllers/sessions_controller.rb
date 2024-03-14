class SessionsController < ApplicationController
  # login user 
  
  def new
  end

  # def create
  #   # binding.pry
  #   # finding user by email

  #   user = User.find_by(email: params[:session][:email].downcase)

  #   if user && user.authenticate(params[:session][:password])
  #     forwarding_url = session[:forwarding_url]
  #     # reseting previous session
  #     reset_session
  #     # checking if remember me is checked or not
  #     params[:session][:remember_me] == '1' ? remember(user) : forget(user)
  #     # user logging in
  #     log_in user
  #     redirect_to forwarding_url || user
  #   else
  #     flash.now[:danger] = 'Invalid email/password combination'
  #     render 'new', status: :unprocessable_entity
  #   end
  # end


  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        log_in user
        redirect_to forwarding_url || user
      else
        message = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  # user logging out
  def destroy
    log_out if logged_in
    redirect_to root_url
  end

  # private
  # def session_params
  #   params.require(:user).permit(:email, :password, :remember_me)
  # end

end