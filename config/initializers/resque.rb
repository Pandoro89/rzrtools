require 'resque/server'
require 'resque/status_server'
require 'resque/failure/redis'
require 'resque/failure/multiple'

Resque::Plugins::Status::Hash.expire_in = 1.day

Resque.redis = "localhost:6379"
Resque.redis.namespace = "resque:rzrtools"

class SecuredResqueServer < Resque::Server
  before do
    redirect '/' unless session[:user_id] and user = User.get(session[:user_id]) and user.admin?
  end
end
