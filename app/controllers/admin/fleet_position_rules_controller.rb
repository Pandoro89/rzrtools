class Admin::FleetPositionRulesController < ApplicationController
  before_filter :require_global_admin
  before_filter :find_fleet_position_rule, :except => [:index,:new,:create]

  def index
    @fleet_position_rules = FleetPositionRule.all.order(:fleet_role => :asc, :points => :desc)
  end

  def new
    @fleet_position_rule = FleetPositionRule.new
  end

  def create
    @fleet_position_rule = FleetPositionRule.create(form_params)
    if @fleet_position_rule.save
      flash[:success] = "Rule saved."
      return redirect_to admin_fleet_position_rules_path
    end
    render 'new'
  end

  def edit
  end

  def update
    if @fleet_position_rule.update(form_params)
      flash[:success] = "Rule saved."
    end
    return redirect_to admin_fleet_position_rules_path
  end

  def destroy
    if @fleet_position_rule.delete
      flash[:success] = "Rule deleted."
    end
    return redirect_to admin_fleet_position_rules_path
  end

  protected
    def find_fleet_position_rule
      @fleet_position_rule ||= FleetPositionRule.find(params[:id])
    end

    def form_params
      params.require(:fleet_position_rule).permit(:eve_group_id, :ship_type_id, :fleet_role, :special_role, :points)
    end
end