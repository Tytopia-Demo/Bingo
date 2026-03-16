# GitHub Actions Workflow Optimization Guide

This document describes the optimization approach used for GitHub Actions workflows in this repository.

## Overview

This repository has been optimized for efficient CI/CD execution by right-sizing runners, setting appropriate timeouts, and implementing job execution tracking.

## Key Optimizations Implemented

### 1. Runner Right-Sizing

All workflows now use standardized runner labels based on job requirements:

- **Small jobs** (linting, security scans): `ubuntu-latest` with 10-15 minute timeouts
- **Medium jobs** (tests, builds): `ubuntu-latest` with 30-60 minute timeouts
- **Large jobs** (integration, releases): `ubuntu-latest` with 60-120 minute timeouts

See [RUNNER_SIZING_GUIDELINES.md](RUNNER_SIZING_GUIDELINES.md) for detailed criteria.

### 2. Timeout Configuration

Every job now has an explicit `timeout-minutes` value:

- Prevents runaway processes from consuming unnecessary resources
- Sized appropriately based on historical job execution times
- Provides early failure detection for hanging jobs

### 3. Job Execution Time Tracking

All workflows now track and report execution metrics:

```yaml
- name: Track job start time
  id: start-time
  run: echo "start_time=$(date +%s)" >> $GITHUB_OUTPUT

# ... job steps ...

- name: Track job end time and report metrics
  if: always()
  run: |
    END_TIME=$(date +%s)
    START_TIME=${{ steps.start-time.outputs.start_time }}
    DURATION=$((END_TIME - START_TIME))
    echo "### Job Execution Metrics" >> $GITHUB_STEP_SUMMARY
    echo "- Actual Duration: ${DURATION} seconds" >> $GITHUB_OUTPUT
```

This enables:
- Visibility into actual job performance
- Data-driven optimization decisions
- Identification of jobs that need runner size adjustments

### 4. Cost Monitoring Tags

Jobs include cost tags for tracking optimization impact:

```yaml
echo "- Cost Tag: test-ruby-${{ matrix.ruby }}" >> $GITHUB_STEP_SUMMARY
```

Tags help categorize runner usage by:
- Job type (lint, test, integration, security-scan)
- Technology version (ruby version)
- Workflow purpose

### 5. Optimization Recommendations

Jobs automatically provide optimization suggestions based on timeout utilization:

- **<25% utilization**: Suggests using smaller runner or reducing timeout
- **>80% utilization**: Warns about potential timeout issues
- **25-80% utilization**: Indicates optimal sizing

## Current Workflows

### frogbot.yml (Security Scanning)
- **Runner**: Small (ubuntu-latest)
- **Timeout**: 15 minutes
- **Rationale**: I/O intensive, low CPU requirements
- **Cost Tag**: security-scan

### ci.yml (Continuous Integration)

#### Lint Job
- **Runner**: Small (ubuntu-latest)
- **Timeout**: 10 minutes
- **Rationale**: Quick style checks
- **Cost Tag**: lint

#### Test Job (Matrix)
- **Runner**: Medium (ubuntu-latest)
- **Timeout**: 45 minutes
- **Rationale**: Full test suite across multiple Ruby versions
- **Cost Tag**: test-ruby-{version}

#### Integration Job
- **Runner**: Medium (ubuntu-latest)
- **Timeout**: 60 minutes
- **Rationale**: More comprehensive testing
- **Cost Tag**: integration
- **Trigger**: Only on master branch or manual dispatch

## Reusable Workflow Templates

Pre-configured templates are available in `.github/workflow-templates/`:

- `ci-test-small.yml`: For lightweight CI jobs
- `ci-test-medium.yml`: For standard test suites
- `ci-test-large.yml`: For intensive integration/release jobs

These templates include:
- Optimal runner configurations
- Appropriate timeouts
- Built-in execution time tracking
- Cost monitoring tags
- Optimization recommendations

## Best Practices

### 1. Choose the Right Runner Size
Start with the smallest runner that meets your needs. Scale up only when:
- Jobs consistently timeout
- Jobs use >80% of timeout duration
- Clear performance bottlenecks exist

### 2. Set Explicit Timeouts
Always specify `timeout-minutes` for every job:
- Prevents runaway processes
- Enables faster failure detection
- Improves resource utilization

### 3. Use Matrix Strategies Wisely
Balance test coverage with resource consumption:
- Use `fail-fast: false` for test matrices to see all failures
- Consider running expensive matrices only on master or tags
- Combine quick jobs to reduce overhead

### 4. Leverage Caching
Use `bundler-cache: true` and other caching strategies:
- Reduces dependency installation time
- Lowers network usage
- Improves job completion speed

### 5. Monitor and Adjust
Regularly review job execution metrics:
- Check timeout utilization percentages
- Identify consistently fast/slow jobs
- Adjust runner sizes and timeouts accordingly

## Conditional Job Execution

Use conditionals to run expensive jobs only when needed:

```yaml
# Only run integration tests on master or manual trigger
if: github.ref == 'refs/heads/master' || github.event_name == 'workflow_dispatch'
```

This saves resources while maintaining quality on important branches.

## Metrics and Reporting

All jobs report to GitHub Step Summary with:
- Runner type used
- Configured timeout
- Actual execution duration
- Timeout utilization percentage
- Cost monitoring tag
- Optimization recommendations

View these metrics in the workflow run summary page.

## Future Enhancements

Potential optimization opportunities:

1. **Self-Hosted Runners**: Evaluate cost-benefit for frequently-run jobs
2. **Parallel Execution**: Further parallelization where beneficial
3. **Selective Testing**: Run only tests affected by code changes
4. **Advanced Caching**: Docker layer caching, build artifact caching
5. **Workflow Triggers**: More granular triggering based on file changes

## Review and Maintenance

These optimizations should be reviewed quarterly:

- Analyze execution time trends
- Adjust timeouts based on actual performance
- Update runner sizes if consistently under/over-utilized
- Refine cost monitoring tags as needed

## References

- [RUNNER_SIZING_GUIDELINES.md](RUNNER_SIZING_GUIDELINES.md) - Detailed runner selection criteria
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Templates](.github/workflow-templates/) - Reusable templates

---

Last Updated: 2024
