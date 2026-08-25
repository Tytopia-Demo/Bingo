# GitHub Actions Deployment Checklist

Use this checklist to ensure a smooth deployment of the GitHub Actions migration.

## Pre-Deployment (Repository Admin)

### 1. Configure Repository Secrets
Navigate to `Settings → Secrets and variables → Actions` and add:

- [ ] `RUBYGEMS_API_TOKEN`
  - Obtain from RubyGems.org account settings
  - Required for: Release workflow
  
- [ ] `GOOGLE_APPLICATION_CREDENTIALS`
  - JSON format service account key
  - Required for: Integration tests in CI and Presubmit workflows
  
- [ ] `DOCUPLOADER_SERVICE_ACCOUNT`
  - JSON format service account key
  - Required for: Documentation publishing in Release and Docs workflows

- [ ] `JF_URL` (if using JFrog)
  - JFrog instance URL
  - Required for: Frogbot security scanning

- [ ] `JF_ACCESS_TOKEN` (if using JFrog)
  - JFrog access token
  - Required for: Frogbot security scanning

### 2. Enable GitHub Actions
- [ ] Verify GitHub Actions is enabled for the repository
- [ ] Check workflow permissions: `Settings → Actions → General → Workflow permissions`
- [ ] Ensure "Read and write permissions" is selected (or configure specific permissions)

### 3. Update Branch Protection Rules
Navigate to `Settings → Branches → Branch protection rules` for `master`/`main`:

- [ ] Remove Kokoro CI checks from required status checks
- [ ] Add new required status checks:
  - [ ] `Lint and Style Check`
  - [ ] `Test on ubuntu-latest with Ruby 3.2`
  - [ ] `Test on macos-latest with Ruby 3.2`
  - [ ] `Test on windows-latest with Ruby 3.2`
  - [ ] (Or configure as needed based on your requirements)

### 4. Configure Notifications
- [ ] Set up Slack/email notifications for workflow failures (optional)
- [ ] Configure who receives notifications for failed nightly builds

## Testing Phase

### 1. Create Test Branch
- [ ] Create a test branch: `git checkout -b test-github-actions`
- [ ] Make a trivial change (e.g., update a comment in README)
- [ ] Push the branch and create a PR

### 2. Verify Presubmit Workflow
- [ ] Confirm presubmit workflow starts automatically
- [ ] Check that all jobs complete successfully
- [ ] Review job logs for any warnings or issues
- [ ] Verify integration tests run (if credentials configured)

### 3. Test CI Workflow
- [ ] Merge the test PR to master
- [ ] Verify CI workflow runs on merge
- [ ] Confirm all OS/Ruby matrix combinations pass
- [ ] Check that link checking completes

### 4. Test Release Workflow (Optional)
**Note:** Only do this if you're ready to publish a release

- [ ] Create a test tag: `git tag v0.0.0-test`
- [ ] Push tag: `git push origin v0.0.0-test`
- [ ] Verify release workflow starts
- [ ] **STOP the workflow before gem publication step**
- [ ] Delete test tag after verification

### 5. Monitor First Nightly Build
- [ ] Wait for first scheduled nightly build (2 AM UTC)
- [ ] Review results
- [ ] Check for any unexpected failures

## Post-Deployment

### 1. Update Documentation
- [ ] Notify team about the migration
- [ ] Share link to `.github/MIGRATION_FROM_KOKORO.md`
- [ ] Update internal documentation/wiki (if applicable)

### 2. Monitor Workflows
First week after deployment:
- [ ] Daily check of workflow runs
- [ ] Review any failures
- [ ] Adjust configurations as needed

### 3. Team Communication
- [ ] Announce migration completion
- [ ] Share workflow status badge URLs
- [ ] Provide support channel for questions

### 4. Clean Up (After 1 Month of Stable Operation)
- [ ] Consider archiving `.kokoro` directory
- [ ] Update any external services that referenced Kokoro
- [ ] Remove any Kokoro-specific documentation

## Rollback Plan (If Needed)

If critical issues are encountered:

1. **Immediate Action:**
   - [ ] Disable GitHub Actions: `Settings → Actions → Disable Actions`
   - [ ] Verify `.kokoro` directory is still intact
   - [ ] Re-enable Kokoro CI (contact Google Cloud DevOps)

2. **Investigation:**
   - [ ] Review workflow logs for errors
   - [ ] Check secrets configuration
   - [ ] Verify branch protection rules

3. **Recovery:**
   - [ ] Fix identified issues
   - [ ] Test fixes in a separate branch
   - [ ] Re-enable GitHub Actions when ready

## Troubleshooting

### Common Issues

**Workflows not starting:**
- Check if GitHub Actions is enabled
- Verify branch protection rules don't block workflows
- Check workflow file syntax with YAML validator

**Secret-related failures:**
- Verify all required secrets are configured
- Check secret names match exactly (case-sensitive)
- Ensure JSON secrets are properly formatted (no extra escaping)

**Integration test failures:**
- Verify `GOOGLE_APPLICATION_CREDENTIALS` is configured
- Check service account has correct permissions
- Review integration test logs for specific errors

**Release workflow issues:**
- Verify `RUBYGEMS_API_TOKEN` is valid
- Check gem version doesn't already exist
- Ensure tag format matches `v*` pattern

## Support Contacts

- **GitHub Actions Issues:** [GitHub Support](https://support.github.com)
- **Repository Issues:** Open an issue in this repository
- **Internal Support:** Contact DevOps team

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ruby Setup Action](https://github.com/ruby/setup-ruby)
- [Migration Guide](.github/MIGRATION_FROM_KOKORO.md)
- [Workflow Documentation](.github/workflows/README.md)

---

**Last Updated:** [Date of deployment]  
**Migration Completed By:** [Your name/team]  
**Review Date:** [Schedule review date, e.g., 1 month after deployment]
