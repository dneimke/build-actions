# CI Pipeline Testing Strategy

## Overview

This document outlines a comprehensive strategy for testing GitHub Actions CI pipelines with Nx change detection logic. The strategy covers testing scenarios with and without changes to ensure the pipeline behaves correctly in all situations.

## Table of Contents

1. [Testing "No Changes" Scenarios](#testing-no-changes-scenarios)
2. [Testing "With Changes" Scenarios](#testing-with-changes-scenarios)
3. [Testing Pull Request Scenarios](#testing-pull-request-scenarios)
4. [Testing Edge Cases](#testing-edge-cases)
5. [Monitoring and Validation](#monitoring-and-validation)
6. [Automated Testing Strategy](#automated-testing-strategy)
7. [Debugging Tips](#debugging-tips)
8. [Expected Behaviors](#expected-behaviors)

## Testing "No Changes" Scenarios

### A. Empty Commits (Recommended)
```bash
# Create an empty commit to test no-changes scenario
git commit --allow-empty -m "test: empty commit to verify no-changes detection"

# Push to trigger workflows
git push origin main
```

### B. Documentation-Only Changes
```bash
# Make changes to files that don't affect projects
echo "# Updated README" >> README.md
git add README.md
git commit -m "docs: update README"
git push origin main
```

### C. Configuration-Only Changes
```bash
# Modify workflow configs (these shouldn't trigger builds)
echo "# Updated config" >> .github/config/workflow-config.yml
git add .github/config/workflow-config.yml
git commit -m "ci: update workflow config"
git push origin main
```

## Testing "With Changes" Scenarios

### A. Library Changes (Should affect dependent apps)
```bash
# Modify the Shared library
echo "// Test comment" >> libs/Shared/EchoService.cs
git add libs/Shared/EchoService.cs
git commit -m "feat: add test comment to EchoService"
git push origin main
```

### B. App Changes (Should only affect the app)
```bash
# Modify the EchoAPI app
echo "// Test comment" >> apps/EchoAPI/Program.cs
git add apps/EchoAPI/Program.cs
git commit -m "feat: add test comment to Program.cs"
git push origin main
```

### C. Cross-Project Changes
```bash
# Make changes to both library and app
echo "// Test comment" >> libs/Shared/EchoService.cs
echo "// Test comment" >> apps/EchoAPI/Program.cs
git add .
git commit -m "feat: update both shared and app"
git push origin main
```

## Testing Pull Request Scenarios

### A. PR with No Changes to Projects
```bash
# Create a branch for docs-only changes
git checkout -b test/docs-only
echo "# Updated docs" >> docs/test.md
git add docs/test.md
git commit -m "docs: add test documentation"
git push origin test/docs-only

# Create PR on GitHub - should show no affected projects
```

### B. PR with Library Changes
```bash
# Create a branch for library changes
git checkout -b test/library-changes
echo "// Test change" >> libs/Shared/EchoService.cs
git add libs/Shared/EchoService.cs
git commit -m "feat: test library change"
git push origin test/library-changes

# Create PR on GitHub - should show Shared and EchoAPI as affected
```

### C. PR with App-Only Changes
```bash
# Create a branch for app-only changes
git checkout -b test/app-only
echo "// Test change" >> apps/EchoAPI/Program.cs
git add apps/EchoAPI/Program.cs
git commit -m "feat: test app change"
git push origin test/app-only

# Create PR on GitHub - should show only EchoAPI as affected
```

## Testing Edge Cases

### A. Force All Projects to Build
```bash
# Modify a file that affects all projects
echo "// Global change" >> Directory.Build.props
git add Directory.Build.props
git commit -m "ci: update global build props"
git push origin main
```

### B. Test with New Projects
```bash
# Add a new project to test detection
mkdir -p apps/TestAPI
echo '<Project Sdk="Microsoft.NET.Sdk.Web"></Project>' > apps/TestAPI/TestAPI.csproj
git add apps/TestAPI/
git commit -m "feat: add new TestAPI project"
git push origin main
```

## Monitoring and Validation

### A. Check Workflow Outputs
Monitor these key outputs in your workflows:
- `has-changes`: Should be `true`/`false` appropriately
- `matrix`: Should contain correct project matrix
- `affected-projects`: Should list correct projects

### B. Verify Job Execution
- **No changes**: Only `detect-changes` job should run
- **With changes**: `build` and `test` jobs should run for affected projects
- **Dependencies**: Ensure dependent projects are included

### C. Check Caching Behavior
- Verify NuGet cache is working
- Check Nx cache is being used
- Monitor build times for improvements

## Automated Testing Strategy

### A. Create Test Workflows
```yaml
# .github/workflows/test-change-detection.yml
name: Test Change Detection

on:
  workflow_dispatch:
    inputs:
      test-type:
        description: 'Type of test to run'
        required: true
        type: choice
        options:
        - no-changes
        - library-changes
        - app-changes
        - all-changes
```

### B. Use GitHub Actions for Testing
```yaml
# Add to your test workflow
- name: Test Nx affected locally
  run: |
    # Test different scenarios
    case "${{ github.event.inputs.test-type }}" in
      "no-changes")
        echo "Testing no changes scenario"
        npx nx show projects --affected --base=main~1 --head=main
        ;;
      "library-changes")
        echo "Testing library changes scenario"
        # Simulate library changes
        ;;
    esac
```

## Debugging Tips

### A. Enable Debug Logging
```yaml
# Add to your workflows
env:
  NX_VERBOSE_LOGGING: true
  ACTIONS_STEP_DEBUG: true
```

### B. Check Nx Graph Locally
```bash
# Test change detection locally
npx nx affected:graph --base=main~1 --head=main

# Check project dependencies
npx nx graph --file=graph.html
```

### C. Verify Git History
```bash
# Check what Nx sees as changes
git diff main~1..main --name-only
npx nx show projects --affected --base=main~1 --head=main
```

## Expected Behaviors

### No Changes Scenario:
- ✅ `has-changes: false`
- ✅ No build/test jobs triggered
- ✅ Summary shows "No affected projects"

### With Changes Scenario:
- ✅ `has-changes: true`
- ✅ Correct projects in matrix
- ✅ Build/test jobs run for affected projects
- ✅ Dependencies included automatically

## Current Setup Overview

### Nx Change Detection Logic
The current setup uses a PowerShell script (`.github/scripts/get-affected-projects.ps1`) that:

1. **Determines base and head branches** based on the GitHub event
2. **Uses Nx affected detection** with `npx nx show projects --affected`
3. **Builds a project matrix** for GitHub Actions parallel execution
4. **Handles dependencies** by including dependent projects

### Key Workflows
- **CI Pipeline** (`ci.yml`): Builds and tests affected projects
- **CD Pipeline** (`cd.yml`): Deploys affected applications
- **PR Validation** (`pr.yml`): Additional validation for pull requests

### Configuration Files
- **Deployment Config** (`.github/config/deployment-config.json`): Defines project types and paths
- **Workflow Config** (`.github/config/workflow-config.yml`): Centralized workflow settings
- **Nx Config** (`nx.json`): Nx workspace configuration

## Testing Checklist

### Before Testing
- [ ] Ensure all workflows are properly configured
- [ ] Verify Nx is working locally (`npx nx --version`)
- [ ] Check that all required secrets are set in GitHub
- [ ] Confirm branch protection rules are configured

### During Testing
- [ ] Monitor workflow execution in GitHub Actions
- [ ] Check that correct projects are identified as affected
- [ ] Verify build and test jobs run only for affected projects
- [ ] Confirm caching is working as expected
- [ ] Validate that dependencies are properly included

### After Testing
- [ ] Review workflow logs for any errors
- [ ] Check that artifacts are published correctly
- [ ] Verify deployment workflows (if applicable)
- [ ] Document any issues or unexpected behaviors

## Troubleshooting Common Issues

### Issue: No Projects Detected as Affected
**Possible Causes:**
- Nx not properly installed or configured
- Git history not available (check `fetch-depth: 0`)
- Branch comparison logic incorrect

**Solutions:**
```bash
# Test locally
npx nx show projects --affected --base=main~1 --head=main

# Check git history
git log --oneline -5
```

### Issue: Wrong Projects Detected
**Possible Causes:**
- Nx dependency graph not up to date
- Project configuration issues
- Incorrect base/head branch comparison

**Solutions:**
```bash
# Regenerate Nx graph
npx nx graph --file=graph.html

# Check project dependencies
npx nx show projects --with-deps
```

### Issue: Build Jobs Not Running
**Possible Causes:**
- Matrix output not properly formatted
- Conditional logic preventing job execution
- GitHub Actions syntax errors

**Solutions:**
- Check workflow YAML syntax
- Verify matrix output format
- Review job conditions and dependencies

## Best Practices

1. **Test Incrementally**: Start with simple scenarios and gradually test more complex ones
2. **Document Results**: Keep track of what works and what doesn't
3. **Use Descriptive Commits**: Make test commits with clear, descriptive messages
4. **Monitor Performance**: Track build times and optimize as needed
5. **Regular Validation**: Periodically test the pipeline to ensure it continues working

## Conclusion

This testing strategy provides a comprehensive approach to validating your Nx-based CI pipeline. By systematically testing different scenarios, you can ensure that your change detection logic works correctly and that your builds are efficient and reliable.

Remember to adapt this strategy as your project grows and evolves. The key is to maintain confidence in your pipeline's ability to correctly identify and process only the necessary changes. 