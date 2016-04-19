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

  def reset_password
    @user = User.find_by_recovery_code(params[:token])

    if !@user 
      flash[:error] = "Invalid recovery code."
      return redirect_to '/'
    end

    pp "----- #{request.post?}"

    if @user and (request.post? || request.patch?)
      pp user_reset_params
      @user.update(user_reset_params)
      @user.password_recovery_code = nil
      @user.password_recovery_code_sent_at = nil
      @user.save
      flash[:success] = "Password reset, please login to continue."
      return redirect_to '/'
    end
  end

  def recover_password
    @email_sent = false
    if request.post?
      pp user_recover_params
      @u = User.where(:email => user_recover_params[:email]).first
      if @u
        @u.send_password_recovery_code
      end

      flash[:success] = "Password recovery email sent."

      @email_sent = true
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

  def user_recover_params
    params.require(:user).permit(:email)
  end

  def user_reset_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end