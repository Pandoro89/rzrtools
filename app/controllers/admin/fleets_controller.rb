class Admin::FleetsController < Admin::ApplicationController
  before_filter :require_military_advisor_or_higher

  def index
  end

  def edit
  end

  def update
  end

  def destroy
  end

  protected 
   # protected params

end