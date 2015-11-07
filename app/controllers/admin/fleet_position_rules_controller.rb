class Admin::ApplicationController < ApplicationController
  before_filter :require_global_admin
  before_filter :find_fleet_position_rule, :except => [:index,:new,:create]

  def index
    @fleet_position_rules = FleetPositionRule.all
  end

  def new
    @fleet_position_rule = FleetPositionRule.new
  end

  def create
    @fleet_position_rule = FleetPositionRule.create(params)
    if @fleet_position_rule.save
      flash[:success] = "Rule saved."
      redirect_to 
    end
    render 'new'
  end

  def edit
  end

  def update
    if @fleet_position_rule.update(user_params)
      flash[:success] = "Rule saved."
    end
    redirect_to 
  end

  def delete
    if @fleet_position_rule.save
      flash[:success] = "Rule deleted."
    end
    redirect_to 
  end

  protected
    def find_fleet_position_rule
      @fleet_position_rule ||= FleetPositionRule.find(params[:id])
    end
end