class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :letsencrypt

  def letsencrypt
    if request.fullpath == '/.well-known/acme-challenge/R5Y0Zu8NrHS2jvrmJUGzJKfsKmOc87p-JemnplUWGpI'
      return render :text => 'R5Y0Zu8NrHS2jvrmJUGzJKfsKmOc87p-JemnplUWGpI.L7ZzjMfTneqEq-tqKGaIN0E8rl4PchxHMpTxhbdMptY'
    end
  end

  def authorize_admin_user
  end

  def authorize_current_user 
    unless current_user
      redirect_to :new_session_path
    end
  end

  def current_user
    return @current_user if @current_user
    return nil unless session[:user_id]
    @current_user ||= User.find_by_id_generation(session[:user_id], session[:user_generation])
  end
  helper_method :current_user


  # Get current user
  # mock_current_user_id cookie overrides everything for testing purposes
  # current_user_id cookie speeds up search, but is still validated against http headers
  # updates database if user info has changed or if force_update is true
  # TODO: Should last_user_id be a session variable?
  def get_character(force_update = false)
    # Total hack for development out of game
    if params[:set_char_id]
      if params[:set_char_id] == "clear"
        cookies.delete :mock_current_set_char_id
      else 
        cookies[:mock_current_char_id] = {:value => params[:set_char_id], :expires => 1.year.from_now.utc }
      end
    end
    if cookies[:mock_current_char_id].to_i > 0
      @current_character = Character.find(cookies[:mock_current_char_id]) # don't bother rescuing for development
      if force_update
        @current_character.updated_at = Time.now
        @current_character.save
      end
      return
    end
    return if request.env["HTTP_EVE_CHARNAME"].blank?
    if cookies[:last_char_id].to_i > 0
      begin
        @current_character = Character.find(cookies[:last_char_id])
              # TODO add rescue just in case the cookie is invalid or out of date
        # Validate @current_character from cookie with environment, including if no env passed
        @current_character = nil if @current_character.char_name != request.env["HTTP_EVE_CHARNAME"]
      rescue
        @current_character = nil
      end
    end
    if @current_character.nil?
      # find character by char_name if it exists
      @current_character = Character.find_or_initialize_from_env(request.env)
    end
    @current_character.set_from_env(env)
    @current_character_changed = true if @current_character.changed?
    @current_character.updated_at = Time.now if force_update
    # Note: if model hasn't changed, .save won't actually bother saving
    @current_character.save
    cookies[:last_char_id] = {:value => @current_character.id, :expires => 1.year.from_now.utc }

    # render :template => 'pages/env'
  end
  
  def get_character_and_force_update
    get_character(true)
  end

  def blue_user?
    if !(@current_character and (BLUE_LIST.include?(@current_character.alliance_id))) and !(current_user and (current_user.has_role? ROLE_BLUE_MEMBER))
      return true
    end
    return false
  end

  def require_igb_blue_or_user
    get_character_and_force_update
    if !(@current_character and @current_character.alliance_id and (@current_character.alliance_id == ALLIANCE_ID or BLUE_LIST.include?(@current_character.alliance_id.to_s))) and !(current_user and (current_user.has_role? ROLE_RAZOR_MEMBER or current_user.has_role? ROLE_BLUE_MEMBER))
      flash.now[:error] = "IGB and Trusted Site Required"
      flash.now[:notice] = "You must be using the Eve in-game-browser and mark the site as 'trusted' to list or create fleets. If you're already in a fleet, you can copy the direct fleet URL while in-game to your out of game browser."
      @request_trust = true
      render :template => 'pages/about'
    end
  end

  def require_igb_razor_or_user
    get_character_and_force_update
    if !(@current_character and @current_character.alliance_id == ALLIANCE_ID) and !(current_user and current_user.has_role? ROLE_RAZOR_MEMBER )
      flash.now[:error] = "IGB and Trusted Site Required"
      flash.now[:notice] = "You must be using the Eve in-game-browser and mark the site as 'trusted' to list or create fleets. If you're already in a fleet, you can copy the direct fleet URL while in-game to your out of game browser."
      @request_trust = true
      render :template => 'pages/about'
    end
  end
  
  def require_igb
    get_character_and_force_update
    unless @current_character
      flash.now[:error] = "IGB and Trusted Site Required"
      flash.now[:notice] = "You must be using the Eve in-game-browser and mark the site as 'trusted' to list or create fleets. If you're already in a fleet, you can copy the direct fleet URL while in-game to your out of game browser."
      @request_trust = true
      render :template => 'pages/about'
    end
  end
  
  def require_global_admin
    unless current_user && current_user.admin? 
      flash[:error] = "You must be an administrator to perform that action."
      redirect_to root_path 
    end
  end

  def require_fc_or_higher
    unless current_user and (current_user.admin? or current_user.scout_commander? or current_user.military_advisor? or current_user.fleet_commander? or current_user.troika?)
      flash[:error] = "You must be an administrator to perform that action."
      redirect_to root_path 
    end
  end

  def require_scout_commander_or_higher
    unless current_user and (current_user.admin? or current_user.scout_commander? or current_user.military_advisor?)
      flash[:error] = "You must be an administrator to perform that action."
      redirect_to root_path 
    end
  end

  def require_military_advisor_or_higher
    unless current_user and (current_user.admin? or current_user.military_advisor?)
      flash[:error] = "You must be an administrator to perform that action."
      redirect_to root_path 
    end
  end

end
