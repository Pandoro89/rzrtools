class ScansController < ApplicationController
  before_action :find_by_token, :only => [:show, :update]

  def index
  end

  def show
  end

  def new
  end

  def create
    return redirect_to :action => "index" if !params[:scan_text] || (params[:scan_text] && params[:scan_text].length == 0)

    @scan = Scan.new
    if @scan.save
      if @current_character
        @scan.update_from_env(@current_character)
      end
      if !@scan.parse_text(params[:scan_text])
        pp params[:scan_text].lines.count
        @scan.destroy
        flash[:error] = "Invalid scan text."
        return redirect_to :action => "index"
      end

      @scan.save
    else
      flash[:error] = "Invalid scan text."
      return redirect_to :action => "index"
    end

    return redirect_to :action => "show", :token => @scan.token
  end

  def update
    return redirect_to :action => "index" if !params[:scan_text]

    if @scan
      @scan.parse_text(params[:scan_text])

      @scan.save
    end


    return redirect_to :action => "show", :token => @scan.token
  end

  protected

    def find_by_token
      @scan = Scan.where(:token => params[:token]).first
    end

    def scan_params
      params.require(:scan).permit(:text)
    end

end