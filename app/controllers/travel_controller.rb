class TravelController < ApplicationController
  before_filter :require_igb_blue_or_user
  autocomplete :solar_system, :name, :class_name => "Eve::SolarSystem"

  def index
  end

  def route
    d = []
    d.concat JumpBridge.all.map {|j| [j.from_solar_system_id,j.to_solar_system_id,1]} if params[:travel][:use_jump_bridges].to_i == 1
    d.concat Eve::SolarSystemJump.all.map { |e| [e.from_solar_system_id,e.to_solar_system_id,5] }
    # TODO: inject bridges
    logger.debug d.size
    # logger.debug d
    g = Graph.new(d)
    results = g.shortest_path(params[:travel][:to_system_id].to_i,params[:travel][:from_system_id].to_i)
    logger.debug [params[:travel][:from_system_id].to_i,params[:travel][:to_system_id].to_i]
    logger.debug results
    @travel_systems = results.map {|r| Eve::SolarSystem.find(r)}

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end
end