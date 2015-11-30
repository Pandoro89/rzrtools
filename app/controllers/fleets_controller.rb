class FleetsController < ApplicationController
  before_filter :get_character, :only => [:join, :index]
  before_filter :require_igb, :only => [:join, :leave]
  before_filter :find_fleet_by_token, :only => [:show, :join, :close, :purge, :edit, :update, :destroy, :special_role, :remove_role, :detail]
  # TODO Find a way to do this as a background task instead
  before_filter :purge_fleets, :only => [:index]
  before_filter :require_igb_razor_or_user, :only => [:index]
  before_filter :require_fc_or_higher, :only => [:create, :manage, :destroy, :close, :fc_rewards]

  # autocomplete :character, :char_name
  autocomplete :group, :name, :class_name => "Eve::Group"
  autocomplete :inv_type, :name, :class_name => "Eve::InvType"

  def autocomplete_character_char_name
    term = params[:term]
    alliance_id = params[:alliance_id] || ALLIANCE_ID
    characters = Character.where('alliance_id = ? AND char_name LIKE ?', alliance_id, "%#{term}%").order(:char_name).all
    render :json => characters.map { |c| {:id => c.id, :value => c.char_name} }
  end

  def index
  end

  def new
    @fleet = Fleet.new(fleet_params) if params[:fleet] and params[:fleet][:fc_name]
    @fleet ||= Fleet.new
  end

  def create
    @fleet = Fleet.where(:fc_name => params[:fleet][:fc_name], :fleet_name => params[:fleet][:fleet_name], :status => 0).first
    if !@fleet.nil?
      return redirect_to :action => "manage", :token => @fleet.token
    end

    @fleet = Fleet.new(fleet_params)
    @fleet.fc_name = 

    if @fleet.save
      @fleet.update_column(:created_by_id, current_user.id)
      redirect_to :action => "manage", :token => @fleet.token
    end

    render 'new'
  end

  def close
    @fleet.status = 1 # set it closed
    @fleet.save
    flash[:success] = "Fleet closed."
    redirect_to :action => "show", :token => @fleet.token
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

  def remove_role
    if params[:fleet_position].include?(:character_id) and params[:fleet_position].include?(:special_role)
      character = Character.find(params[:fleet_position][:character_id])
      @fleet.remove_with_special_role(character, params[:fleet_position][:special_role])
    end

    logger.debug request.xhr?
    logger.debug "--- xhr" if request.xhr?

    @special_roles = FleetPosition.where(:fleet => @fleet, :special_role => params[:fleet_position][:special_role])
    respond_to do |format|
      format.html { render 'special_role' ,:layout => !request.xhr? }
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

  def ping_helper
    # Do nothing for now
  end

  def rewards
    @month = params[:date][:month] if params[:date] and params[:date][:month]
    @month ||= DateTime.now.strftime("%m") 
    @year = params[:date][:year] if params[:date] and params[:date][:year]
    @year ||= DateTime.now.strftime("%Y")
    @other_pilot_rewards = Fleet.pilot_rewards_other_points(@month, @year)
    @logi_pilot_rewards = Fleet.pilot_rewards_logistics_points(@month, @year)
  end

  def fc_rewards
    @month = params[:date][:month] if params[:date] and params[:date][:month]
    @month ||= DateTime.now.strftime("%m") 
    @year = params[:date][:year] if params[:date] and params[:date][:year]
    @year ||= DateTime.now.strftime("%Y")

    @fc_rewards = Fleet.fc_rewards(@month, @year)
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