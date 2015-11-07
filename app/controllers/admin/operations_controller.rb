class Admin::OperationsController < Admin::ApplicationController
  before_filter :require_global_admin
end