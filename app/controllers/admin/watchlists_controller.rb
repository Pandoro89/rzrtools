class Admin::WatchlistsController < Admin::ApplicationController
  before_filter :require_scout_commander_or_higher
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
    @watchlist = Watchlist.create(form_params)
    api = EAAL::API.new("", "")
    api.scope = "eve"
    result = api.CharacterID(:names => @watchlist.char_name)
    c = result.characters.first
    if c and c.name == @watchlist.char_name
      result2 = api.CharacterInfo(:characterID => c.characterID)
      @watchlist.corp_id = result2.corporationID
      @watchlist.corp_name = result2.corporation
      begin
        @watchlist.alliance_id = result2.allianceID if result2.allianceID
        @watchlist.alliance_name = result2.alliance if result2.alliance
        Eve::AllianceCache.add_or_update(result2.allianceID,result2.alliance) if result2.allianceID and !result2.alliance.nil?
      rescue NoMethodError
        # NOOP
      end
    end
    
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
      params.require(:watchlist).permit(:last_seen_at, :char_name, :solar_system_name, :solar_system_id, :comment, :wl_type, :ship_type_name, :ship_type_id)
    end
end