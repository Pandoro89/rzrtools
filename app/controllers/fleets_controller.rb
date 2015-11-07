class FleetsController < ApplicationController
  before_filter :get_character, :only => [:join, :index]
  before_filter :require_igb, :only => [:join, :leave]
  before_filter :find_fleet_by_token, :only => [:show, :join, :purge, :edit, :update, :destroy, :special_role, :detail]
  # TODO Find a way to do this as a background task instead
  before_filter :purge_fleets, :only => [:index]
  before_filter :require_igb_razor_or_user, :only => [:index, :create]

  autocomplete :character, :char_name
  autocomplete :group, :name, :class_name => "Eve::Group"
  autocomplete :inv_type, :name, :class_name => "Eve::InvType"

  def index

  end

  def new
  end

  def create
    @fleet = Fleet.create(fleet_params)

    redirect_to :action => "show", :token => @fleet.token
  end

  def close
  end

  def update
  end

  def join
    if @fleet
      @fleet.join(@current_character)
    end
  end

  def special_role
    if params[:fleet_position].include?(:character_id) and params[:fleet_position].include?(:special_role)
      character = Character.find(params[:fleet_position][:character_id])
      @fleet.join_with_special_role(character, params[:fleet_position][:special_role])
    end

    @special_roles = FleetPosition.where(:fleet => @fleet, :special_role => params[:fleet_position][:special_role])
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end

  def show
  end

  def manage
  end

  def detail
    @fleet_positions = FleetPosition.where(:fleet => @fleet)
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end

  def destroy
  end

  protected ###################################################

    def find_fleet_by_token
      @fleet = Fleet.where(:token => params[:token], :status => 0).first
    end

    def purge_fleets
      #noop
    end


    def fleet_params
      params.require(:fleet).permit(:fc_name, :fleet_name, :fleet_time, :fleet_coms, :description)
    end

end