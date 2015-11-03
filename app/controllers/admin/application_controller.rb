class Admins::ApplicationController < ApplicationController
  before_filter :authorize_ma_or_higher

  def authorize_ma_or_higher
    current_user.has_role? :admin or current_user.has_role? :military_advisor or current_user.has_role? :troika
  end
end
