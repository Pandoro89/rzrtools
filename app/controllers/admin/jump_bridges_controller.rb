class Admin::JumpBridgesController < Admin::ApplicationController
  before_filter :require_scout_commander_or_higher
  before_filter :find_jump_bridge, :except => [:index, :new, :create]

  def index
    @jump_bridges = JumpBridge.all
  end

  def edit
  end

  def new
    @jump_bridge = JumpBridge.new
  end

  def create
    if params[:jump_bridge][:from_solar_system_id].to_i == 0 or params[:jump_bridge][:to_solar_system_id].to_i == 0
      @jump_bridge = JumpBridge.new(form_params)
      flash[:error] = "Invalid system."
      return render 'new'
    end

    @jump_bridge = JumpBridge.create(form_params)
    if @jump_bridge.save
      flash[:success] = "Jump bridge saved."
      return  redirect_to admin_jump_bridges_path
    end
    render 'new'
  end

  def update
    if @jump_bridge.update(form_params)
      flash[:success] = "Jump bridge saved."
      return redirect_to admin_jump_bridges_path
    end
    render 'edit'
  end

  def destroy
    if @jump_bridge.delete
      flash[:success] = "Jump bridge deleted."
    end

    redirect_to admin_jump_bridges_path
  end

  protected
    def find_jump_bridge
      @jump_bridge ||= JumpBridge.find(params[:id])
    end

    def form_params
      params.require(:jump_bridge).permit(:from_moon, :from_planet, :to_moon, :to_planet, :from_solar_system_id, :to_solar_system_id)
    end
end