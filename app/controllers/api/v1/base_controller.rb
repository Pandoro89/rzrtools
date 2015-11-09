class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :destroy_session
  before_filter :authenticate_user

  def destroy_session
    request.session_options[:skip] = true
  end

  def authenticate_user
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    log.debug "Token: #{token}"

    if token and ActiveSupport::SecurityUtils.secure_compare("d117C96w8z853vF8664T8wj40Y1N67Qz9TP70xpq1y6484br3z3330Ei7nO51ShS", token)
      true
    else
      return render(json: {}, status: 403)
    end
  end
end