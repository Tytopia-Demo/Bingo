# Example config.ru demonstrating how to mount health and readiness endpoints
# in a Rack application using Google Auth library
#
# To run: rackup examples/config.ru
#
# Then visit:
# http://localhost:9292/health
# http://localhost:9292/ready

require 'googleauth'

# Optional: Add custom health checks
Google::Auth::HealthCheckApp.add_check("database") do
  # Example database check
  # In a real app: ActiveRecord::Base.connection.active?
  true
end

Google::Auth::ReadinessCheckApp.add_check("cache") do
  # Example cache check
  # In a real app: $redis.ping == "PONG"
  true
end

# Mount health endpoint
map '/health' do
  run Google::Auth::HealthCheckApp
end

# Mount readiness endpoint
map '/ready' do
  run Google::Auth::ReadinessCheckApp
end

# Your main application
map '/' do
  run lambda { |env|
    [200, {'Content-Type' => 'text/plain'}, ['Health: /health, Readiness: /ready']]
  }
end
