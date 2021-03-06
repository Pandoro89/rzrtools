class Admin::UsersController < Admin::ApplicationController
  before_action :require_military_advisor_or_higher
  before_action :find_user, :except => [:index]

  def index
    params[:page] = 1 if !params[:page]

    if params[:name]
      use_name = "%#{params[:name]}%"
      @users = User.where("username LIKE ? OR username LIKE ? OR 0<(SELECT COUNT(*) FROM characters WHERE user_id = `users`.id AND char_name LIKE ?)",use_name,use_name,use_name).paginate(:page => params[:page]) if params[:name]
  end
    @users ||= User.paginate(:page => params[:page])
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
      @user.delete_role(r.name)
    end
    redirect_to admin_user_path
  end

  def destroy
    if @user.destroy
      flash[:success] = "User deleted."
    else
      flash[:error] = "The use could not be deleted."
    end

    return redirect_to admin_user_path
  end

  protected 
    def find_user
      @user = User.where(id: params[:id]).try(:first)
      redirect_to admin_users_path if @user.nil?
    end
end