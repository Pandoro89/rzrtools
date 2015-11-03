class WatchlistsController < ApplicationController
  autocomplete :alliance_cache, :name, :class_name => "Eve::AllianceCache"

  def index
    @watchlists = []
    @watchlists = Watchlist.where(:alliance_id => params[:alliance_id]).order(:last_seen_at => :desc) if params[:alliance_id]
  end

  def alliance
    @watchlists = []
    @watchlists = Watchlist.where(:alliance_id => params[:alliance_id]).order(:last_seen_at => :desc) if params[:alliance_id]

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end
end