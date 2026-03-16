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

spec_dir = File.expand_path File.join(File.dirname(__FILE__))
$LOAD_PATH.unshift spec_dir
$LOAD_PATH.uniq!

require "googleauth"
require "googleauth/health_checker"
require "spec_helper"
require "rack"
require "multi_json"

describe Google::Auth::HealthChecker do
  describe Google::Auth::HealthCheckApp do
    after do
      # Reset custom checks after each test
      described_class.instance_variable_set(:@custom_checks, nil)
    end

    describe ".call" do
      let(:env) { Rack::MockRequest.env_for("http://example.com/health") }

      it "returns 200 OK when healthy" do
        status, headers, body = described_class.call(env)
        expect(status).to eq 200
      end

      it "returns JSON content type" do
        status, headers, body = described_class.call(env)
        expect(headers["Content-Type"]).to eq "application/json"
      end

      it "includes status in response" do
        status, headers, body = described_class.call(env)
        response = MultiJson.load(body.first)
        expect(response["status"]).to eq "healthy"
      end

      it "includes timestamp in response" do
        status, headers, body = described_class.call(env)
        response = MultiJson.load(body.first)
        expect(response["timestamp"]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      end

      it "includes Ruby version in details" do
        status, headers, body = described_class.call(env)
        response = MultiJson.load(body.first)
        expect(response["details"]["ruby_version"]).to eq RUBY_VERSION
      end

      context "with custom checks" do
        it "runs custom checks that pass" do
          described_class.add_check("test_check") { true }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 200
          expect(response["status"]).to eq "healthy"
          expect(response["details"]["test_check"]).to eq "ok"
        end

        it "returns 503 when a custom check fails" do
          described_class.add_check("failing_check") { false }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 503
          expect(response["status"]).to eq "unhealthy"
          expect(response["details"]["failing_check"]).to eq "failed"
        end

        it "handles exceptions in custom checks" do
          described_class.add_check("error_check") { raise "Something went wrong" }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 503
          expect(response["status"]).to eq "unhealthy"
          expect(response["details"]["error_check"]).to match(/error: Something went wrong/)
        end

        it "runs multiple custom checks" do
          described_class.add_check("check1") { true }
          described_class.add_check("check2") { true }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 200
          expect(response["details"]["check1"]).to eq "ok"
          expect(response["details"]["check2"]).to eq "ok"
        end
      end
    end

    describe "#call" do
      it "delegates to class method" do
        env = Rack::MockRequest.env_for("http://example.com/health")
        instance = described_class.new

        status, headers, body = instance.call(env)
        expect(status).to eq 200
      end
    end
  end

  describe Google::Auth::ReadinessCheckApp do
    after do
      # Reset custom checks after each test
      described_class.instance_variable_set(:@custom_checks, nil)
    end

    describe ".call" do
      let(:env) { Rack::MockRequest.env_for("http://example.com/ready") }

      it "returns 200 OK when ready" do
        status, headers, body = described_class.call(env)
        expect(status).to eq 200
      end

      it "returns JSON content type" do
        status, headers, body = described_class.call(env)
        expect(headers["Content-Type"]).to eq "application/json"
      end

      it "includes status in response" do
        status, headers, body = described_class.call(env)
        response = MultiJson.load(body.first)
        expect(response["status"]).to eq "ready"
      end

      it "includes timestamp in response" do
        status, headers, body = described_class.call(env)
        response = MultiJson.load(body.first)
        expect(response["timestamp"]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
      end

      it "includes Ruby version in details" do
        status, headers, body = described_class.call(env)
        response = MultiJson.load(body.first)
        expect(response["details"]["ruby_version"]).to eq RUBY_VERSION
      end

      context "with custom checks" do
        it "runs custom checks that pass" do
          described_class.add_check("test_check") { true }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 200
          expect(response["status"]).to eq "ready"
          expect(response["details"]["test_check"]).to eq "ready"
        end

        it "returns 503 when a custom check fails" do
          described_class.add_check("failing_check") { false }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 503
          expect(response["status"]).to eq "not_ready"
          expect(response["details"]["failing_check"]).to eq "not_ready"
        end

        it "handles exceptions in custom checks" do
          described_class.add_check("error_check") { raise "Something went wrong" }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 503
          expect(response["status"]).to eq "not_ready"
          expect(response["details"]["error_check"]).to match(/error: Something went wrong/)
        end

        it "runs multiple custom checks" do
          described_class.add_check("check1") { true }
          described_class.add_check("check2") { true }

          status, headers, body = described_class.call(env)
          response = MultiJson.load(body.first)

          expect(status).to eq 200
          expect(response["details"]["check1"]).to eq "ready"
          expect(response["details"]["check2"]).to eq "ready"
        end
      end
    end

    describe "#call" do
      it "delegates to class method" do
        env = Rack::MockRequest.env_for("http://example.com/ready")
        instance = described_class.new

        status, headers, body = instance.call(env)
        expect(status).to eq 200
      end
    end
  end

  describe "Module aliases" do
    it "provides HealthCheckApp alias" do
      expect(Google::Auth::HealthCheckApp).to eq(
        Google::Auth::HealthChecker::HealthCheckApp
      )
    end

    it "provides ReadinessCheckApp alias" do
      expect(Google::Auth::ReadinessCheckApp).to eq(
        Google::Auth::HealthChecker::ReadinessCheckApp
      )
    end
  end
end
