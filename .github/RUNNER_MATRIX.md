# Runner Type Matrix

This document provides a standardized matrix for selecting runners based on job complexity and requirements.

## Runner Size Categories

| Size | Runner Label | vCPU | RAM | Storage | Cost Factor | Use Cases |
|------|-------------|------|-----|---------|-------------|-----------|
| Small | `ubuntu-latest` | 2 | 7GB | 14GB SSD | 1x | Linting, security scans, quick tests |
| Medium | `ubuntu-latest` | 2 | 7GB | 14GB SSD | 1x | Full test suites, builds, deployments |
| Large | `ubuntu-latest-8-cores`* | 8 | 32GB | 14GB SSD | 4x | Performance tests, large builds |

*Note: Larger runners may require GitHub Enterprise or self-hosted infrastructure

## Job Complexity Levels

### Level 1: Small (Low Complexity)
**Characteristics:**
- Execution time: <5 minutes
- CPU usage: <40%
- Memory usage: <2GB
- No heavy compilation
- Minimal dependencies

**Examples:**
- Code linting (RuboCop)
- YAML/JSON validation
- Documentation checks
- Security vulnerability scanning
- Simple shell scripts

**Recommended Runner:** Small (`ubuntu-latest`)
**Timeout:** 10-15 minutes

---

### Level 2: Medium (Moderate Complexity)
**Characteristics:**
- Execution time: 5-30 minutes
- CPU usage: 40-70%
- Memory usage: 2-5GB
- Moderate compilation
- Standard test suites

**Examples:**
- Unit test suites
- Integration tests
- Gem building and packaging
- Multi-version test matrices
- Static analysis tools

**Recommended Runner:** Medium (`ubuntu-latest`)
**Timeout:** 30-60 minutes

---

### Level 3: Large (High Complexity)
**Characteristics:**
- Execution time: 30+ minutes
- CPU usage: >70%
- Memory usage: >5GB
- Heavy compilation
- Extensive test coverage

**Examples:**
- Full integration test suites
- Performance benchmarking
- Large-scale parallel tests
- Complex build processes
- Release workflows with multiple steps

**Recommended Runner:** Large (`ubuntu-latest` or larger if available)
**Timeout:** 60-120 minutes

---

## Job Category Matrix

| Job Category | Typical Size | Runner | Timeout | Priority |
|--------------|-------------|--------|---------|----------|
| Linting | Small | ubuntu-latest | 10 min | High |
| Security Scan | Small | ubuntu-latest | 15 min | High |
| Unit Tests | Medium | ubuntu-latest | 30 min | High |
| Integration Tests | Medium | ubuntu-latest | 45 min | Medium |
| Performance Tests | Large | ubuntu-latest-8-cores | 90 min | Low |
| Gem Build | Medium | ubuntu-latest | 20 min | High |
| Documentation | Small | ubuntu-latest | 15 min | Medium |
| Release | Medium | ubuntu-latest | 30 min | Critical |

## Platform-Specific Runners

### Linux (Primary)
- **Default:** `ubuntu-latest` (Ubuntu 22.04)
- **Older:** `ubuntu-20.04` (for compatibility testing)
- **Use:** Most CI/CD jobs

### macOS (When Needed)
- **Default:** `macos-latest` (macOS 13)
- **Cost:** ~10x Linux runners
- **Use:** macOS-specific testing only

### Windows (When Needed)
- **Default:** `windows-latest` (Windows Server 2022)
- **Cost:** ~2x Linux runners
- **Use:** Windows-specific testing only

## Self-Hosted Runner Considerations

### When to Use Self-Hosted Runners
- Jobs running very frequently (>100/day)
- Special hardware requirements
- Private network access needed
- Significant cost savings over GitHub-hosted
- Need for persistent build caches

### When to Use GitHub-Hosted Runners
- Occasional jobs
- Standard build environments
- No special requirements
- Prefer maintenance-free infrastructure
- Need clean environment for each run

## Runner Selection Decision Tree

```
Start
  |
  ├─ Is job critical path? (blocks merges/deploys)
  |    ├─ YES → Use appropriate sized runner, DO NOT reduce timeout
  |    └─ NO → Continue
  |
  ├─ Expected execution time?
  |    ├─ <5 min → Small runner, 10-15 min timeout
  |    ├─ 5-30 min → Medium runner, 30-60 min timeout
  |    └─ >30 min → Large runner, 60-120 min timeout
  |
  ├─ Resource requirements?
  |    ├─ CPU-intensive → Consider larger runner
  |    ├─ Memory-intensive → Consider larger runner
  |    └─ I/O-intensive → Small/Medium sufficient
  |
  ├─ Frequency?
  |    ├─ Very frequent (>100/day) → Consider self-hosted
  |    └─ Normal → GitHub-hosted fine
  |
  └─ Platform requirements?
       ├─ Linux → ubuntu-latest (preferred)
       ├─ macOS → macos-latest (only if necessary)
       └─ Windows → windows-latest (only if necessary)
```

## Cost Optimization Guidelines

### High Priority (Implement First)
1. Right-size all runners based on actual usage
2. Add timeouts to prevent runaway jobs
3. Use small runners for quick jobs
4. Enable caching for dependencies

### Medium Priority (Implement Next)
1. Combine lightweight jobs to reduce overhead
2. Run expensive jobs conditionally (master only, etc.)
3. Use matrix strategies with fail-fast judiciously
4. Implement selective testing based on changes

### Low Priority (Nice to Have)
1. Consider self-hosted for very frequent jobs
2. Optimize test suites for faster execution
3. Implement advanced caching strategies
4. Use job dependencies to optimize parallelization

## Monitoring and Adjustment

### Key Metrics to Track
1. **Timeout Utilization:** Actual duration / Timeout
2. **Cost per Job Type:** Runner minutes by category
3. **Success Rate:** By runner type
4. **Queue Time:** Time waiting for runner

### Adjustment Triggers

**Upsize Runner When:**
- Timeout utilization consistently >80%
- Jobs timing out regularly
- CPU/memory constraints evident
- Clear performance bottlenecks

**Downsize Runner When:**
- Timeout utilization consistently <25%
- Low resource utilization (<40% CPU/memory)
- Job completes very quickly
- I/O bound with idle CPU

**Adjust Timeout When:**
- Utilization consistently very high or very low
- Job characteristics change (more/fewer tests)
- Runner size changes
- External dependencies change

## Example Configurations

### Small Job (Linting)
```yaml
lint:
  runs-on: ubuntu-latest
  timeout-minutes: 10
  steps:
    - uses: actions/checkout@v3
    - run: bundle exec rubocop
```

### Medium Job (Testing)
```yaml
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

### Large Job (Integration)
```yaml
integration:
  runs-on: ubuntu-latest  # or ubuntu-latest-8-cores if available
  timeout-minutes: 90
  steps:
    - uses: actions/checkout@v3
    - run: bundle exec rake integration
```

## Tags for Cost Monitoring

Use consistent tags in job names or outputs:

- `lint` - Linting jobs
- `test-{language}-{version}` - Test jobs
- `integration` - Integration tests
- `security-scan` - Security scanning
- `build` - Build jobs
- `deploy` - Deployment jobs
- `release` - Release workflows

These enable cost tracking and optimization analysis.

---

Last Updated: 2024
