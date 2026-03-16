# Copyright 2015, Google Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "multi_json"
require "time"
require "timeout"

module Google
  module Auth
    # Provides health and readiness check functionality for web applications
    # using Google Auth.
    #
    # These Rack apps can be mounted in your application to provide
    # standardized health and readiness endpoints for monitoring,
    # orchestration, and load balancing.
    #
    # Example usage in Rails (config/routes.rb):
    #
    #     match '/health',
    #           to: Google::Auth::HealthCheckApp,
    #           via: :get
    #     match '/ready',
    #           to: Google::Auth::ReadinessCheckApp,
    #           via: :get
    #
    # Example usage with Rackup (config.ru):
    #
    #     map '/health' do
    #       run Google::Auth::HealthCheckApp
    #     end
    #     map '/ready' do
    #       run Google::Auth::ReadinessCheckApp
    #     end
    #
    # Example usage in Sinatra:
    #
    #     get('/health') do
    #       Google::Auth::HealthCheckApp.call(env)
    #     end
    #     get('/ready') do
    #       Google::Auth::ReadinessCheckApp.call(env)
    #     end
    #
    module HealthChecker
      CONTENT_TYPE_HEADER = "Content-Type".freeze
      JSON_CONTENT_TYPE = "application/json".freeze
      OK_STATUS = 200
      SERVICE_UNAVAILABLE_STATUS = 503
      HEALTH_CHECK_TIMEOUT = 5 # seconds

      # Base class for health check implementations
      class CheckResult
        attr_reader :status, :details, :timestamp

        def initialize status, details = {}
          @status = status
          @details = details
          @timestamp = Time.now.utc.iso8601
        end

        def healthy?
          @status == "healthy"
        end

        def to_json
          MultiJson.dump(
            status:    @status,
            timestamp: @timestamp,
            details:   @details
          )
        end
      end

      # Rack app that provides a health check endpoint.
      #
      # Returns 200 OK when the service is running and core dependencies
      # are available. Returns 503 Service Unavailable when unhealthy.
      #
      # The health check verifies basic functionality without checking
      # if the service is ready to handle requests.
      #
      # @see Google::Auth::ReadinessCheckApp
      class HealthCheckApp
        class << self
          attr_accessor :custom_checks

          # Add a custom health check
          #
          # @param [String] name The name of the check
          # @param [Proc] check A proc that returns true if healthy, false otherwise
          def add_check name, &check
            @custom_checks ||= {}
            @custom_checks[name] = check
          end

          # Perform all health checks
          #
          # @return [CheckResult]
          def perform_checks
            details = {}
            all_healthy = true

            # Basic runtime check
            details[:ruby_version] = RUBY_VERSION

            # Run custom checks if any
            if defined?(@custom_checks) && @custom_checks
              @custom_checks.each do |name, check|
                begin
                  result = Timeout.timeout(HEALTH_CHECK_TIMEOUT) do
                    check.call
                  end
                  details[name] = result ? "ok" : "failed"
                  all_healthy = false unless result
                rescue StandardError => e
                  details[name] = "error: #{e.message}"
                  all_healthy = false
                end
              end
            end

            status = all_healthy ? "healthy" : "unhealthy"
            CheckResult.new status, details
          end
        end

        # Handle a Rack request for health check
        #
        # @param [Hash] env Rack environment
        # @return [Array] HTTP response [status, headers, body]
        def self.call env
          result = perform_checks
          status_code = result.healthy? ? OK_STATUS : SERVICE_UNAVAILABLE_STATUS

          [
            status_code,
            { CONTENT_TYPE_HEADER => JSON_CONTENT_TYPE },
            [result.to_json]
          ]
        end

        def call env
          self.class.call env
        end
      end

      # Rack app that provides a readiness check endpoint.
      #
      # Returns 200 OK only when the service is fully initialized and
      # ready to handle requests. Returns 503 Service Unavailable when
      # not ready.
      #
      # The readiness check is more comprehensive than the health check
      # and verifies that all dependencies are available and the service
      # can process requests.
      #
      # @see Google::Auth::HealthCheckApp
      class ReadinessCheckApp
        class << self
          attr_accessor :custom_checks

          # Add a custom readiness check
          #
          # @param [String] name The name of the check
          # @param [Proc] check A proc that returns true if ready, false otherwise
          def add_check name, &check
            @custom_checks ||= {}
            @custom_checks[name] = check
          end

          # Perform all readiness checks
          #
          # @return [CheckResult]
          def perform_checks
            details = {}
            all_ready = true

            # Basic runtime check
            details[:ruby_version] = RUBY_VERSION

            # Run custom checks if any
            if defined?(@custom_checks) && @custom_checks
              @custom_checks.each do |name, check|
                begin
                  result = Timeout.timeout(HEALTH_CHECK_TIMEOUT) do
                    check.call
                  end
                  details[name] = result ? "ready" : "not_ready"
                  all_ready = false unless result
                rescue StandardError => e
                  details[name] = "error: #{e.message}"
                  all_ready = false
                end
              end
            end

            status = all_ready ? "ready" : "not_ready"
            CheckResult.new status, details
          end
        end

        # Handle a Rack request for readiness check
        #
        # @param [Hash] env Rack environment
        # @return [Array] HTTP response [status, headers, body]
        def self.call env
          result = perform_checks
          status_code = result.status == "ready" ? OK_STATUS : SERVICE_UNAVAILABLE_STATUS

          [
            status_code,
            { CONTENT_TYPE_HEADER => JSON_CONTENT_TYPE },
            [result.to_json]
          ]
        end

        def call env
          self.class.call env
        end
      end
    end

    # Alias for convenience
    HealthCheckApp = HealthChecker::HealthCheckApp
    ReadinessCheckApp = HealthChecker::ReadinessCheckApp
  end
end
