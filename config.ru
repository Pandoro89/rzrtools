# This file is used by Rack-based servers to start the application.

# unicorn-worker-killer
if defined?(Unicorn)
  require "unicorn/worker_killer"
  use Unicorn::WorkerKiller::Oom, 220*(1024**2), 260*(1024**2)
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
