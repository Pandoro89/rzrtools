class Admin::RashMembersController < Admin::ApplicationController
  before_action :require_global_admin

end