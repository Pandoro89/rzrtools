class Admin::UsersController < Admin::ApplicationController
  before_filter :require_military_advisor_or_higher
  before_filter :find_user, :except => [:index]

  def index
    params[:page] = 1 if !params[:page]
    @users = User.paginate(:page => params[:page])
  end

  def show
  end

  def role_add
    r = Role.find(params[:role][:id])
    @user.add_role r.name
    redirect_to admin_user_path
  end

  def role_delete
    r = Role.find(params[:role_id])
    if r 
      @user.remove_role r.name
    end
    redirect_to admin_user_path
  end

  def delete
    if @user.delete
      flash[:success] = "User deleted."
    else
      flash[:error] = "The use could not be deleted."
    end
  end

  protected 
    def find_user
      @user = User.find(params[:id])
      redirect_to admin_users_path if @user.nil?
    end
end