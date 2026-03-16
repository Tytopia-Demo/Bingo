# GitHub Actions Runner Sizing Guidelines

This document provides standardized guidelines for selecting appropriate runner types and sizes for GitHub Actions workflows in this repository.

## Runner Categories

### Small Runners
**Runner Label:** `ubuntu-latest` (2-core, 7GB RAM)

**Use Cases:**
- Security scanning (Frogbot, dependency checks)
- Linting and code style checks
- Documentation generation
- Simple shell scripts
- Fast unit tests (<5 minutes)

**Timeout:** 15-30 minutes

**Cost-Benefit:** Best for lightweight jobs that don't require heavy computation

---

### Medium Runners
**Runner Label:** `ubuntu-latest` (2-core, 7GB RAM) or `ubuntu-latest-4-cores` (if available)

**Use Cases:**
- Full test suites (unit + integration)
- Building and packaging gems
- Multi-version test matrices
- Moderate compilation tasks

**Timeout:** 30-60 minutes

**Cost-Benefit:** Balanced performance for standard CI/CD tasks

---

### Large Runners
**Runner Label:** `ubuntu-latest-8-cores` or self-hosted runners (if available)

**Use Cases:**
- Extensive integration tests
- Performance benchmarking
- Large-scale parallel test execution
- Heavy compilation or build tasks
- Release processes

**Timeout:** 60-120 minutes

**Cost-Benefit:** Use sparingly for jobs that genuinely need extra resources

---

## Job-Specific Recommendations

### Security Scanning (Frogbot)
- **Runner:** Small (`ubuntu-latest`)
- **Timeout:** 15 minutes
- **Rationale:** Dependency scanning is I/O intensive but not CPU heavy

### CI Test Suite
- **Runner:** Medium (`ubuntu-latest`)
- **Timeout:** 45 minutes
- **Rationale:** Running tests across multiple Ruby versions requires moderate resources

### Release/Deploy
- **Runner:** Medium (`ubuntu-latest`)
- **Timeout:** 30 minutes
- **Rationale:** Gem building and publishing has moderate resource needs

### Documentation
- **Runner:** Small (`ubuntu-latest`)
- **Timeout:** 20 minutes
- **Rationale:** Documentation generation is typically lightweight

---

## Best Practices

1. **Always Set Timeouts:** Every job should have an explicit `timeout-minutes` to prevent runaway processes
2. **Monitor Job Duration:** Use job execution time tracking to identify optimization opportunities
3. **Right-Size Runners:** Start with small runners and scale up only when needed
4. **Use Matrix Strategies Wisely:** Balance test coverage with resource consumption
5. **Leverage Caching:** Use actions/cache to reduce build times and resource usage
6. **Tag Self-Hosted Runners:** Use cost monitoring tags for tracking optimization impact

---

## Monitoring and Optimization

### Key Metrics to Track
- Job execution time
- Runner utilization (CPU, memory)
- Workflow success/failure rates
- Queue times

### When to Upgrade Runner Size
- Jobs consistently timing out
- Jobs taking >80% of timeout duration
- High memory usage causing OOM errors
- CPU-bound tasks showing clear bottlenecks

### When to Downgrade Runner Size
- Jobs completing in <25% of timeout duration
- Low CPU/memory utilization (<40% peak)
- I/O bound tasks with idle CPU time

---

## Workflow Configuration Examples

### Small Job Example
```yaml
jobs:
  security-scan:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v3
      - name: Run security scan
        run: bundle exec rake security:scan
```

### Medium Job Example
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 45
    strategy:
      matrix:
        ruby: [2.6, 2.7, 3.0, 3.1]
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
      - run: bundle exec rake test
```

### Large Job Example
```yaml
jobs:
  integration:
    runs-on: ubuntu-latest
    timeout-minutes: 90
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
      - run: bundle exec rake integration
```

---

## Cost Optimization Tips

1. **Combine Jobs:** Merge lightweight jobs to reduce overhead
2. **Use Conditionals:** Skip unnecessary jobs based on changed files
3. **Optimize Dependencies:** Cache gems and dependencies
4. **Fail Fast:** Use fail-fast strategies to stop unnecessary work
5. **Schedule Wisely:** Run expensive jobs only when needed (e.g., nightly, pre-release)

---

## Review Schedule

These guidelines should be reviewed quarterly to ensure they remain aligned with:
- Actual job performance metrics
- Changes in available runner types
- Cost optimization goals
- Project requirements

Last Updated: 2024
