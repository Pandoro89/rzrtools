class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authorize_admin_user
  end

  def authorize_current_user 
    unless current_user
      redreict_to :new_session_path
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

  def require_igb_razor_or_user
    if !(@current_character and @current_character.alliance_id == ALLIANCE_ID) and !(current_user and current_user.has_role? "Razor Member")
      flash.now[:error] = "IGB and Trusted Site Required"
      flash.now[:notice] = "You must be using the Eve in-game-browser and mark the site as 'trusted' to list or create fleets. If you're already in a fleet, you can copy the direct fleet URL while in-game to your out of game browser."
      @request_trust = true
      render :template => 'pages/about'
    end
  end
  
  def require_igb
    unless @current_character
      flash.now[:error] = "IGB and Trusted Site Required"
      flash.now[:notice] = "You must be using the Eve in-game-browser and mark the site as 'trusted' to list or create fleets. If you're already in a fleet, you can copy the direct fleet URL while in-game to your out of game browser."
      @request_trust = true
      render :template => 'pages/about'
    end
  end
  
  def require_global_admin
    unless @current_user && @current_user.global_admin? 
      flash[:error] = "You must be an administrator to perform that action."
      redirect_to root_path 
    end
  end
end
