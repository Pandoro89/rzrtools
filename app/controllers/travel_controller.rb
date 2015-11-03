class TravelController < ApplicationController

  autocomplete :solar_system, :name, :class_name => "Eve::SolarSystem"

  def index
  end

  def route
    d = Eve::SolarSystemJump.all.map { |e| [e.from_solar_system_id,e.to_solar_system_id,5] }
    # TODO: inject bridges
    g = Graph.new(d)
    results = g.shortest_path(params[:travel][:to_system_id].to_i,params[:travel][:from_system_id].to_i)
    logger.debug [params[:travel][:from_system_id].to_i,params[:travel][:to_system_id].to_i]
    logger.debug results
    @travel_systems = results[0].map {|r| Eve::SolarSystem.find(r)}

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end
end