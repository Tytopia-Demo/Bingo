# Examples

This directory contains example applications demonstrating how to use the Google Auth library features.

## Health and Readiness Checks

### Sinatra Example

Run the Sinatra example to see health and readiness endpoints in action:

```bash
ruby examples/health_check_example.rb
```

Then visit:
- http://localhost:4567/health - Health check endpoint
- http://localhost:4567/ready - Readiness check endpoint

### Rackup Example

Run the Rackup example:

```bash
rackup examples/config.ru
```

Then visit:
- http://localhost:9292/health - Health check endpoint
- http://localhost:9292/ready - Readiness check endpoint

## Response Format

Both endpoints return JSON responses with the following format:

```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z",
  "details": {
    "ruby_version": "2.7.0",
    "database": "ok"
  }
}
```

- **200 OK**: Service is healthy/ready
- **503 Service Unavailable**: Service is unhealthy/not ready
