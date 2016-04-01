class UsersController < ApplicationController
  before_action :find_user, :except => [:ping, :new, :create, :reset_password, :recover_password]
  #before_action :require_global_admin, :except => [:ping, :show, :profile] # show has it's own auth check
  # TODO Check for valid user ID

  def me 
  end

  def ping 
  end

  def profile 
  end

  def update
    if @user.update(user_params)
      @user.save
      redirect_to '/'
    else
      render 'profile'
    end
  end

  def eve_api_key
    key = Eve::ApiKey.create(eve_api_params)
    if key.save
    end

    redirect_to 
  end

  def new 
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      session[:user_id] = @user.id
      session[:user_generation] = @user.generation

      redirect_to api_keys_path
    else
      render 'new'
    end
  end


  protected ###################################################

  def find_user
    @user = current_user
    if @user.nil?
      redirect_to new_session_path
    end
  end

  def user_params
    params.require(:user).permit(:username,:email, :password, :password_confirmation, :main_char_id,api_keys_attributes:[:key_code,:vcode,:_destroy,:id])
  end

  def eve_api_params
    params.require(:eve_api).permit(:key_code, :vcode)
  end

end