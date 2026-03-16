# Reusable Workflow Templates

This directory contains pre-configured workflow templates with optimal runner settings for common CI/CD tasks.

## Available Templates

### ci-test-small.yml
**Purpose:** Lightweight CI jobs
**Runner:** Small (ubuntu-latest, 2-core, 7GB RAM)
**Timeout:** 30 minutes

**Use for:**
- Linting and code style checks
- Quick unit tests (<5 minutes)
- Documentation generation
- Security scans

**Usage:**
```yaml
name: My Workflow
on: [push]

jobs:
  lint:
    uses: ./.github/workflow-templates/ci-test-small.yml
    with:
      ruby-version: '3.1'
```

---

### ci-test-medium.yml
**Purpose:** Standard test suites
**Runner:** Medium (ubuntu-latest, 2-core, 7GB RAM)
**Timeout:** 60 minutes

**Use for:**
- Full test suites (unit + integration)
- Multi-version test matrices
- Gem building and packaging
- Standard CI tasks

**Usage:**
```yaml
name: My Workflow
on: [push]

jobs:
  test:
    uses: ./.github/workflow-templates/ci-test-medium.yml
    with:
      ruby-versions: '["2.6", "2.7", "3.0", "3.1"]'
```

---

### ci-test-large.yml
**Purpose:** Intensive jobs
**Runner:** Large (ubuntu-latest, consider 8-core if available)
**Timeout:** 120 minutes

**Use for:**
- Extensive integration tests
- Performance benchmarking
- Large-scale parallel execution
- Release processes

**Usage:**
```yaml
name: My Workflow
on: [push]

jobs:
  integration:
    uses: ./.github/workflow-templates/ci-test-large.yml
    with:
      enable-performance-tests: true
```

---

## Features

All templates include:

### ✅ Job Execution Time Tracking
Automatically tracks and reports:
- Job start and end times
- Total execution duration
- Timeout utilization percentage

### ✅ Cost Monitoring Tags
Each job includes cost tracking tags for:
- Runner type identification
- Job category classification
- Performance analysis

### ✅ Optimization Recommendations
Automatic suggestions based on timeout utilization:
- Warning if job uses >80% of timeout
- Recommendation if job uses <25% of timeout
- Confirmation when optimally sized

### ✅ Pre-configured Settings
- Appropriate runner sizes
- Optimal timeout values
- Caching enabled
- Fail-fast strategies

---

## Creating Custom Templates

When creating new templates, follow these guidelines:

### 1. Choose Appropriate Runner Size
```yaml
jobs:
  my-job:
    runs-on: ubuntu-latest  # Small/Medium
    # or
    runs-on: ubuntu-latest-8-cores  # Large (if available)
```

### 2. Set Explicit Timeout
```yaml
jobs:
  my-job:
    timeout-minutes: 30  # Based on job complexity
```

### 3. Add Time Tracking
```yaml
steps:
  - name: Track job start time
    id: start-time
    run: echo "start_time=$(date +%s)" >> $GITHUB_OUTPUT

  # ... your steps ...

  - name: Track job end time
    if: always()
    run: |
      END_TIME=$(date +%s)
      DURATION=$((END_TIME - ${{ steps.start-time.outputs.start_time }}))
      echo "Duration: ${DURATION} seconds"
```

### 4. Add Cost Tags
```yaml
- name: Report metrics
  run: |
    echo "- Cost Tag: my-job-category" >> $GITHUB_STEP_SUMMARY
```

### 5. Enable Caching
```yaml
- uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true
```

---

## Best Practices

### Do's ✅
- Use the smallest template that meets your needs
- Start with small, scale up if needed
- Monitor timeout utilization metrics
- Enable caching for dependencies
- Add descriptive job names

### Don'ts ❌
- Don't use large runners for simple tasks
- Don't omit timeout values
- Don't ignore optimization recommendations
- Don't run expensive jobs on every PR
- Don't use macOS/Windows runners unless necessary

---

## Template Selection Guide

| Job Type | Template | Typical Duration | When to Use |
|----------|----------|------------------|-------------|
| Linting | Small | <5 min | Code style, YAML validation |
| Security Scan | Small | 5-10 min | Dependency scanning, SAST |
| Unit Tests | Medium | 10-30 min | Test suite, single version |
| Matrix Tests | Medium | 15-45 min | Multi-version testing |
| Integration Tests | Medium/Large | 30-60 min | Full system testing |
| Performance Tests | Large | 60+ min | Benchmarks, load tests |
| Release | Medium | 20-40 min | Build, package, publish |

---

## Monitoring and Optimization

### Check These Metrics
1. **Timeout Utilization**: Target 25-80%
2. **Success Rate**: Should be high (>95%)
3. **Duration Trends**: Watch for increases
4. **Cost per Job**: Track runner minutes

### When to Adjust
- **<25% utilization**: Consider smaller runner or reduced timeout
- **>80% utilization**: Consider larger runner or increased timeout
- **Frequent timeouts**: Increase timeout or optimize job
- **Slow trends**: Investigate performance degradation

### How to Adjust
1. Update template timeout values
2. Change runner size in template
3. Add/improve caching
4. Optimize job steps
5. Parallelize where possible

---

## Support

For questions or issues with templates:
1. Check [RUNNER_SIZING_GUIDELINES.md](../RUNNER_SIZING_GUIDELINES.md)
2. Review [WORKFLOW_OPTIMIZATION.md](../WORKFLOW_OPTIMIZATION.md)
3. Check [RUNNER_MATRIX.md](../RUNNER_MATRIX.md)
4. Review job execution metrics in workflow runs

---

Last Updated: 2024
