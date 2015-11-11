class WatchlistsController < ApplicationController
  before_filter :require_igb_razor_or_user
  autocomplete :alliance_cache, :name, :class_name => "Eve::AllianceCache"

  def index
    @watchlists = []
    if params[:alliance_id]
      @watchlists = Watchlist.where(:alliance_id => params[:alliance_id]).order(:last_seen_at => :desc)
    elsif params[:watchlist] and params[:watchlist][:alliance] and @alliance = Eve::AllianceCache.where(:name => params[:watchlist][:alliance]).first
      @watchlists = Watchlist.where(:alliance_id => @alliance.id ).order(:last_seen_at => :desc)
    else
      @watchlists = Watchlist.where("last_seen_at >= ?",DateTime.now-6.hours).order(:last_seen_at => :desc)
    end
  end

  def alliance
    @watchlists = []
    @watchlists = Watchlist.where(:alliance_id => params[:alliance_id]).order(:last_seen_at => :desc) if params[:alliance_id]

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
    end
  end
end