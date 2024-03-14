class UsersController < ApplicationController
  # http_basic_authenticate_with name: "ahmadwaseem", password: "123456"

  # USERS = { "lifo" => "world" }
  # TOKEN = "secret"

  # before_action :authenticate


  # User Signup


  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  # user index
  # def index
  #   @users = User.all
  # end

  def index
    # @users = User.all
    # @users = User.paginate(page: params[:page])
    # changed for activated accounts
    @users = User.where(activated: true).paginate(page:
    params[:page])
  end


  # display all users
  def show
    @user = User.find(params[:id])
    # show only activated accounts
    redirect_to root_url and return unless @user.activated
  end

  # create new user
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    # binding.pry
    
    if @user.save
      # after saving user ending activation email
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url

      # redirect_to login_path
      # reset_session
      # log_in @user
      # flash[:success] = "Account created Successfully!"
      # redirect_to login_path
      # redirect_to user_url(@user) same use
    else
      render 'new', status: :unprocessable_entity
    end
  end

  # edit user
  def edit
    @user = User.find(params[:id])
  end  

  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  # destroy user

  def destroy
    # binding.pry

    User.find(params[:id]).destroy
    flash[:success] = "User Deleted Successfully"
    redirect_to users_url, status: :see_other
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Before filters
  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in
    store_location
    flash[:danger] = "Please log in." 
    redirect_to login_url, status: :see_other
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    # redirect_to(root_url, status: :see_other) unless current_user?(@user)

    if !current_user?(@user)
      redirect_to(root_url, status: :see_other)
    end

  end

  # Confirms an admin user.
  def admin_user
    # redirect_to(root_url, status: :see_other) unless current_user.admin?
    
    if !current_user.admin?
      redirect_to(root_url, status: :see_other)
    end

  end

  # def authenticate
  #   authenticate_or_request_with_http_digest do |username|
  #     USERS[username]
  #   end
  # end

  # def authenticate
  #   authenticate_or_request_with_http_token do |token, options|
  #     ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
  #   end
  # end
end