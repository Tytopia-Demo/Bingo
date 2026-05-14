# GitHub Actions Workflows

This directory contains GitHub Actions workflows for continuous integration, deployment, and automation.

## Workflows Overview

### 🔄 CI Workflow (`ci.yml`)
**Purpose**: Continuous integration testing across multiple platforms and Ruby versions.

**Triggers**:
- Push to `master`/`main` branch
- Pull requests to `master`/`main` branch
- Daily schedule (2 AM UTC)
- Manual dispatch

**Jobs**:
- **test**: Runs tests on matrix of OS (Linux, macOS, Windows) and Ruby versions (2.5-3.2)
- **link-check**: Validates documentation links (post-merge only)
- **coverage**: Generates and uploads code coverage reports

**Key Features**:
- Multi-OS testing
- Multiple Ruby version support
- Code coverage tracking
- Test artifact upload on failure

---

### ✅ Presubmit Checks (`presubmit.yml`)
**Purpose**: Pre-merge validation for pull requests.

**Triggers**:
- Pull request events (opened, synchronize, reopened)

**Jobs**:
- **lint**: Code style validation with RuboCop
- **test-matrix**: Multi-OS and multi-Ruby version testing
- **integration-test**: Integration tests (requires credentials)
- **summary**: Aggregates and reports results

**Key Features**:
- Fast feedback for PRs
- Prevents merging code that fails tests
- Integration test support for internal PRs

---

### 🚀 Release Workflow (`release.yml`)
**Purpose**: Automated gem publishing and release management.

**Triggers**:
- Push tags matching `v*` pattern
- Manual dispatch with tag input

**Jobs**:
- **release**: Builds and publishes gem to RubyGems.org
- **notify**: Reports release status

**Key Features**:
- Automated gem building
- RubyGems.org publishing
- GitHub Release creation
- Documentation publishing
- Version validation

**Required Secrets**:
- `RUBYGEMS_API_TOKEN`: RubyGems API token for publishing
- `DOCUPLOADER_SERVICE_ACCOUNT`: Service account for documentation upload

---

### 🌙 Nightly Build (`nightly.yml`)
**Purpose**: Extended testing including edge cases and development versions.

**Triggers**:
- Daily schedule (2 AM UTC)
- Manual dispatch

**Jobs**:
- **nightly-test**: Extended matrix including Ruby `head` version
- **report**: Generates report and creates issues on failure

**Key Features**:
- Tests with Ruby development version
- More comprehensive test suite
- Automatic issue creation on failure
- Failure notification

---

### 📚 Documentation Workflow (`docs.yml`)
**Purpose**: Automated documentation generation and publishing.

**Triggers**:
- Push to `master`/`main` (when docs-related files change)
- Release published
- Manual dispatch

**Jobs**:
- **build-docs**: Generates YARD documentation
- **publish-docs**: Publishes to GitHub Pages and devsite

**Key Features**:
- Automatic doc generation on code changes
- GitHub Pages deployment
- Devsite integration
- Documentation artifact archival

**Required Secrets**:
- `DOCUPLOADER_SERVICE_ACCOUNT`: Service account for documentation upload

---

### 🔒 Security Workflow (`security.yml`)
**Purpose**: Automated security scanning and vulnerability detection.

**Triggers**:
- Push to `master`/`main`
- Pull requests
- Weekly schedule (Mondays at 9 AM UTC)
- Manual dispatch

**Jobs**:
- **dependency-review**: Reviews dependency changes in PRs
- **bundler-audit**: Scans for known vulnerabilities
- **codeql**: Static code analysis for security issues
- **secret-scan**: Detects accidentally committed secrets

**Key Features**:
- Vulnerability detection
- Dependency security review
- Secret scanning
- CodeQL analysis

---

### 🐸 Frogbot Security Scan (`frogbot.yml`)
**Purpose**: JFrog security scanning for dependencies.

**Triggers**:
- Pull requests
- Push to `master` branch
- Daily schedule
- Manual dispatch

**Required Secrets**:
- `JF_URL`: JFrog instance URL
- `JF_ACCESS_TOKEN`: JFrog access token

---

## Required Secrets

Configure the following secrets in repository settings (`Settings → Secrets and variables → Actions`):

### Essential Secrets
| Secret Name | Purpose | Required For |
|------------|---------|-------------|
| `RUBYGEMS_API_TOKEN` | Publishing gems to RubyGems.org | Release workflow |
| `GOOGLE_APPLICATION_CREDENTIALS` | Integration testing | CI, Presubmit |
| `DOCUPLOADER_SERVICE_ACCOUNT` | Documentation publishing | Release, Docs |

### Optional Secrets
| Secret Name | Purpose | Required For |
|------------|---------|-------------|
| `JF_URL` | JFrog instance URL | Frogbot |
| `JF_ACCESS_TOKEN` | JFrog access token | Frogbot |

### Automatic Secrets
| Secret Name | Purpose | Provided By |
|------------|---------|-------------|
| `GITHUB_TOKEN` | GitHub API access | GitHub (automatic) |

---

## Workflow Status Badges

Add these badges to your README to show workflow status:

```markdown
[![CI](https://github.com/googleapis/google-auth-library-ruby/workflows/CI/badge.svg)](https://github.com/googleapis/google-auth-library-ruby/actions/workflows/ci.yml)
[![Presubmit Checks](https://github.com/googleapis/google-auth-library-ruby/workflows/Presubmit%20Checks/badge.svg)](https://github.com/googleapis/google-auth-library-ruby/actions/workflows/presubmit.yml)
[![Security](https://github.com/googleapis/google-auth-library-ruby/workflows/Security/badge.svg)](https://github.com/googleapis/google-auth-library-ruby/actions/workflows/security.yml)
```

---

## Development Tips

### Testing Workflows Locally
While you can't run GitHub Actions locally, you can test the commands:

```bash
# Test what CI runs
bundle install
bundle exec rubocop
bundle exec rake test
bundle exec rake integration
bundle exec rspec

# Test full CI suite
bundle exec rake ci
```

### Debugging Failed Workflows
1. Check the workflow run logs in the Actions tab
2. Look for the specific job and step that failed
3. Review error messages and stack traces
4. Test the failing command locally
5. Add debug output if needed:
   ```yaml
   - run: echo "Debug info: ${{ matrix.ruby }}"
   ```

### Modifying Workflows
1. Edit the YAML file
2. Validate YAML syntax: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"`
3. Test locally if possible
4. Create a PR to test in a real environment
5. Monitor the workflow run

### Manual Workflow Dispatch
Some workflows can be triggered manually:
1. Go to `Actions` tab
2. Select the workflow
3. Click `Run workflow`
4. Fill in any required inputs
5. Click `Run workflow` button

---

## Migration from Kokoro

This repository was migrated from Kokoro CI to GitHub Actions. See [MIGRATION_FROM_KOKORO.md](../MIGRATION_FROM_KOKORO.md) for details about the migration process and mapping of old Kokoro jobs to new workflows.

---

## Best Practices

1. **Keep workflows DRY**: Use composite actions or reusable workflows for repeated logic
2. **Use matrix builds**: Test across multiple versions and platforms efficiently
3. **Cache dependencies**: Use `bundler-cache: true` with `ruby/setup-ruby`
4. **Fail fast when appropriate**: Use `fail-fast: false` for comprehensive testing
5. **Add concurrency controls**: Prevent multiple runs on the same branch
6. **Use secrets securely**: Never log secrets, use masked inputs
7. **Monitor workflow duration**: Optimize long-running jobs
8. **Keep workflows focused**: Separate concerns (CI, release, security)

---

## Support

For issues with workflows:
1. Check workflow logs in the Actions tab
2. Review GitHub Actions documentation: https://docs.github.com/en/actions
3. Open an issue in the repository
4. Contact the DevOps team

For GitHub Actions questions:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ruby setup action](https://github.com/ruby/setup-ruby)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
