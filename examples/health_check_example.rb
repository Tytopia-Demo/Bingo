#!/usr/bin/env ruby
# Copyright 2015, Google Inc.
# All rights reserved.
#
# Example demonstrating how to use health and readiness endpoints
# with Google Auth library in a Rack application.

require 'googleauth'
require 'sinatra'

# Configure health checks with custom dependencies
Google::Auth::HealthCheckApp.add_check("custom_service") do
  # Example: Check if a custom service is available
  # In a real app, this might check database connectivity, etc.
  true
end

Google::Auth::ReadinessCheckApp.add_check("initialization") do
  # Example: Check if the app is fully initialized
  # In a real app, this might verify that all required services are ready
  true
end

# Mount the health endpoint
get '/health' do
  Google::Auth::HealthCheckApp.call(env)
end

# Mount the readiness endpoint
get '/ready' do
  Google::Auth::ReadinessCheckApp.call(env)
end

# Example application endpoint that requires authentication
get '/' do
  "Welcome! Check /health and /ready for status information."
end

# To run this example:
# ruby examples/health_check_example.rb
#
# Then visit:
# http://localhost:4567/health
# http://localhost:4567/ready
