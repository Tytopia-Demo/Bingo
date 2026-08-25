# Migration from Kokoro CI to GitHub Actions

This document describes the migration from Kokoro CI to GitHub Actions for the google-auth-library-ruby repository.

## Overview

This repository has been migrated from Kokoro CI (Google's internal CI system) to GitHub Actions to standardize CI/CD processes across the organization.

## Workflow Mapping

### Kokoro Configuration → GitHub Actions Workflows

| Kokoro Job Type | GitHub Actions Workflow | Trigger |
|----------------|------------------------|---------|
| Presubmit (Linux/macOS/Windows) | `presubmit.yml` | Pull requests |
| Continuous (Linux/macOS/Windows) | `ci.yml` | Push to master/main |
| Post | `ci.yml` (link-check job) | Push to master/main |
| Nightly | `nightly.yml` | Daily schedule (2 AM UTC) |
| Release | `release.yml` | Push tags matching `v*` |

## Key Changes

### 1. Environment Variables and Secrets

**Before (Kokoro):**
- Stored in Kokoro keystore
- Accessed via `KOKORO_GFILE_DIR`

**After (GitHub Actions):**
Configure the following secrets in GitHub repository settings:

- `RUBYGEMS_API_TOKEN` - For publishing gems to RubyGems.org
- `GOOGLE_APPLICATION_CREDENTIALS` - For integration tests (JSON format)
- `DOCUPLOADER_SERVICE_ACCOUNT` - For documentation publishing (JSON format)

### 2. Multi-OS Matrix Builds

**Before:**
- Separate configuration files for Linux, macOS, Windows
- `.kokoro/continuous/linux.cfg`, `osx.cfg`, `windows.cfg`

**After:**
- Single workflow file with matrix strategy
- Configured in workflow YAML files

### 3. Build Process

**Before (Kokoro):**
```bash
# Downloaded from master repository
curl https://raw.githubusercontent.com/.../build.sh
```

**After (GitHub Actions):**
```yaml
- run: bundle install
- run: bundle exec rake ci
```

### 4. Artifact Publishing

**Before:**
- Kokoro sponge logs
- Custom artifact handling

**After:**
- GitHub Actions artifacts API
- Built-in artifact retention and download

### 5. Status Badges

**Before:**
- No visible status badges (internal Kokoro)

**After:**
- GitHub Actions status badges in README
```markdown
[![CI](https://github.com/.../workflows/CI/badge.svg)](.../actions/workflows/ci.yml)
```

## Workflows Details

### CI Workflow (`ci.yml`)
- **Triggers**: Push to master/main, pull requests, daily schedule
- **Jobs**: 
  - Multi-OS testing (Linux, macOS, Windows)
  - Multiple Ruby versions (2.5-3.2)
  - Code coverage reporting
  - Link checking (post-merge)

### Presubmit Workflow (`presubmit.yml`)
- **Triggers**: Pull requests
- **Jobs**:
  - Linting (RuboCop)
  - Multi-OS test matrix
  - Integration tests (if credentials available)

### Release Workflow (`release.yml`)
- **Triggers**: Tags matching `v*`, manual dispatch
- **Jobs**:
  - Build and publish gem to RubyGems
  - Create GitHub Release
  - Publish documentation

### Nightly Workflow (`nightly.yml`)
- **Triggers**: Daily at 2 AM UTC, manual dispatch
- **Jobs**:
  - Extended testing matrix (includes Ruby head)
  - Full integration test suite
  - Automatic issue creation on failure

### Documentation Workflow (`docs.yml`)
- **Triggers**: Push to master, releases, manual dispatch
- **Jobs**:
  - Generate YARD documentation
  - Publish to GitHub Pages
  - Publish to devsite

## Testing the Migration

### Local Testing
Before the migration, test locally:
```bash
# Install dependencies
bundle install

# Run the full CI suite
bundle exec rake ci

# Run individual tasks
bundle exec rubocop
bundle exec rake test
bundle exec rake integration
bundle exec rspec
```

### First Actions Run
1. Create a test branch
2. Make a minor change
3. Open a pull request
4. Verify all presubmit checks pass

## Rollback Plan

If issues are encountered:
1. The `.kokoro` directory has been preserved
2. Kokoro configurations remain intact
3. Can temporarily re-enable Kokoro while debugging GitHub Actions

## Migration Checklist

- [x] Create GitHub Actions workflows
- [x] Add status badges to README
- [x] Configure Dependabot for dependency updates
- [ ] Configure repository secrets
- [ ] Test presubmit workflow
- [ ] Test CI workflow
- [ ] Test release workflow (use test tag)
- [ ] Notify team of migration
- [ ] Monitor first few workflow runs
- [ ] Archive Kokoro configurations (optional)

## Required Actions

### Repository Administrators
1. **Configure Secrets**: Go to Settings → Secrets and variables → Actions
   - Add `RUBYGEMS_API_TOKEN`
   - Add `GOOGLE_APPLICATION_CREDENTIALS` (as JSON string)
   - Add `DOCUPLOADER_SERVICE_ACCOUNT` (as JSON string)

2. **Enable Actions**: Ensure GitHub Actions is enabled for the repository

3. **Update Branch Protection**: Update branch protection rules to require GitHub Actions checks instead of Kokoro

4. **Notification Settings**: Configure notification preferences for workflow failures

### Developers
1. **Update Local Workflows**: Familiarize with new CI process
2. **Badge URLs**: Update any external references to build status
3. **Release Process**: Review new release workflow before next release

## Support

For issues or questions about the migration:
- Open an issue in the repository
- Contact the DevOps team
- Refer to [GitHub Actions documentation](https://docs.github.com/en/actions)

## Additional Resources

- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Ruby setup action](https://github.com/ruby/setup-ruby)
- [GitHub Actions marketplace](https://github.com/marketplace?type=actions)
