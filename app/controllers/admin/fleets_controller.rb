class Admin::FleetsController < Admin::ApplicationController
  before_action :require_military_advisor_or_higher

  before_action :find_fleet_by_token, :only => [:show, :join, :close, :purge, :edit, :update, :destroy, :special_role, :remove_role, :detail]

  def index
    @fleets = Fleet.where(status: 0) if current_user and current_user.admin?
    @fleets ||= Fleet.open
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  protected 
   # protected params

    def find_fleet_by_token
      @fleet = Fleet.where(:token => params[:token]).first
    end

end