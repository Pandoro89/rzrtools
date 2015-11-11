class ApiKeysController < ApplicationController
  before_filter :find_user
  before_filter :find_api_key, :only => [:edit, :update, :destroy]

  def index
    @api_keys = @user.api_keys
  end

  def new
    @api_key = Eve::ApiKey.new
  end

  def create
    @api_key = Eve::ApiKey.new(eve_api_params)
    @api_key.user_id = @user.id
    @api_key.user = @user
    if @api_key.save
      @api_key.update_access_mask
      @api_key.update_characters
      flash[:success] = "API Key saved."
      return redirect_to api_keys_path
    end
    render 'new'
  end

  def edit
  end

  def update
    if @api_key.update(eve_api_params)
      flash[:success] = "API Key saved."
      return redirect_to api_keys_path
    end
    render 'edit'
  end

  def destroy
    if @api_key.delete
      flash[:success] = "API Key deleted."
    end
    return redirect_to api_keys_path
  end


  protected

    def find_api_key
      @api_key ||= Eve::ApiKey.find(params[:id])
    end

    def find_user
      @user = current_user
      if @user.nil?
        redirect_to new_session_path
      end
    end

    def eve_api_params
      params.require(:eve_api_key).permit(:key_code, :vcode)
    end
end