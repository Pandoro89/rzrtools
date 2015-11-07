class Admin::WatchlistsController < Admin::ApplicationController
  before_filter :find_watchlist, :except => [:index, :new, :create]

  def index
    @watchlists = Watchlist.all.order(:alliance_name => :asc, :char_name => :asc)
  end

  def edit
  end

  def new
    @watchlist = Watchlist.new
  end

  def create
    @watchlist = JumpBridge.create(form_params)
    if @watchlist.save
      flash[:success] = "Watchlist saved."
      return  redirect_to admin_watchlists_path
    end
    render 'new'
  end

  def update
    if @watchlist.update(form_params)
      flash[:success] = "Watchlist saved."
      return redirect_to admin_watchlists_path
    end
    render 'edit'
  end

  def destroy
    if @watchlist.delete
      flash[:success] = "Watchlist deleted."
    end

    redirect_to admin_watchlists_path
  end

  protected
    def find_watchlist
      @watchlist ||= Watchlist.find(params[:id])
    end

    def form_params
      params.require(:watchlist).permit(:from_moon, :from_planet, :to_moon, :to_planet, :from_solar_system_id, :to_solar_system_id)
    end
end