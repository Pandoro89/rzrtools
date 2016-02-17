class SignaturesController < ApplicationController
  before_filter :require_igb_razor_or_user

  def index
  end

end