class Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :destroy_session
  force_ssl if: :ssl_configured?

  def ssl_configured?
    !Rails.env.development?
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def authenticate_by_key
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    if token and ActiveSupport::SecurityUtils.secure_compare("d117C96w8z853vF8664T8wj40Y1N67Qz9TP70xpq1y6484br3z3330Ei7nO51ShS", token)
      true
    else
      return render(json: {}, status: 403)
    end
  end

  def authenticate_by_user

    if user = authenticate_with_http_basic { |u, p| User.login(u, p, request.remote_ip, true) }
      @current_user = user
    else
      request_http_basic_authentication
    end

  end
end