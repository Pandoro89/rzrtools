#require 'resque' 
require 'resque/server'
require 'resque/status_server'
require 'resque/failure/redis'
require 'resque/failure/multiple'
require 'resque-scheduler'
require 'resque/scheduler/server'

Resque::Plugins::Status::Hash.expire_in = 1.day

Resque.redis = "localhost:6379"
#Resque.redis.namespace = "resque:rzrtools"
#Resque::Scheduler.dynamic = true
