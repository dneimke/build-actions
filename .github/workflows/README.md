# Workflow Testing Guide

This document provides step-by-step instructions for manually testing the CI/CD workflows to verify they work correctly after configuration changes.

## Overview

The repository has two main workflows:
- **CI - Build and Test**: Builds, tests, and creates artifacts
- **CD - Deploy to Environments**: Downloads artifacts and deploys to environments

## Prerequisites

- Access to the GitHub repository
- Ability to push commits to trigger workflows
- Understanding of the current project structure (kebab-case naming)

## Step 1: Access GitHub Actions

1. **Open your repository** in a web browser
2. **Click on the "Actions" tab** at the top of the repository
3. **You should see two workflows:**
   - `CI - Build and Test`
   - `CD - Deploy to Environments`

## Step 2: Test CI Workflow

### Option A: Trigger via Code Change (Recommended)

```bash
# In your local terminal, make a small test change
echo "# Test CI workflow - $(date)" >> README.md
git add README.md
git commit -m "test: trigger CI workflow to verify kebab-case paths"
git push origin main
```

### Option B: Manual Trigger

1. **Click on "CI - Build and Test"** workflow
2. **Click "Run workflow"** button (top right)
3. **Select branch:** `main`
4. **Click "Run workflow"**

## Step 3: Monitor CI Workflow

### Jobs to Watch

1. **`load-config`**
   - ✅ Should complete quickly
   - ✅ Loads workflow configuration

2. **`detect-changes`**
   - ✅ Should detect changes from your commit
   - ✅ Should output matrix with affected projects

3. **`build`** (matrix job)
   - ✅ Should build `echo-api` project
   - ✅ Should show kebab-case paths (`apps/echo-api`)
   - ✅ Should upload artifacts with correct names

4. **`test`** (matrix job)
   - ✅ Should run tests for `echo-api`
   - ✅ Should complete successfully

5. **`summary`**
   - ✅ Should show overall workflow results

### Key Verification Points

- ✅ All jobs complete successfully (green checkmarks)
- ✅ Matrix shows `echo-api` project (not `EchoAPI`)
- ✅ Build artifacts are created
- ✅ No path-related errors in logs
- ✅ Artifact name is `echo-api-build-artifacts`

### Check Artifacts

1. **Click on the completed workflow run**
2. **Scroll down to "Artifacts" section**
3. **Verify you see:** `echo-api-build-artifacts`

## Step 4: Test CD Workflow

Once CI succeeds, test the CD workflow:

### Manual CD Trigger

1. **Go back to Actions tab**
2. **Click on "CD - Deploy to Environments"**
3. **Click "Run workflow"** button
4. **Configure parameters:**
   - **Environment:** `staging` (safer than production)
   - **App name:** Leave empty (deploy all) or enter `echo-api`
5. **Click "Run workflow"**

## Step 5: Monitor CD Workflow

### Jobs to Watch

1. **`load-config`**
   - ✅ Should complete quickly
   - ✅ Loads workflow configuration

2. **`determine-changes`**
   - ✅ Should detect changes (since we just pushed)
   - ✅ Should output matrix with `echo-api` project
   - ✅ Should show kebab-case paths

3. **`consolidate-deployment`**
   - ✅ Should consolidate outputs
   - ✅ Debug steps should show valid matrix JSON

4. **`download-artifacts`** ⚠️ **Critical Step**
   - ✅ Should download `echo-api-build-artifacts`
   - ✅ Should upload `echo-api-deployment-artifacts`
   - ✅ **No path errors** - this was the main issue we fixed

5. **`prepare-artifacts`**
   - ✅ Should download and consolidate artifacts
   - ✅ Should upload `echo-api-final-artifacts`

6. **`deploy-staging`**
   - ✅ Should download final artifacts
   - ✅ Should attempt deployment (may fail if Azure not configured)
   - ✅ Should show success notification

7. **`deployment-summary`**
   - ✅ Should show overall deployment results

### Key Verification Points

- ✅ All jobs complete successfully
- ✅ No "artifact not found" errors
- ✅ Matrix generation works correctly
- ✅ Paths use kebab-case (`apps/echo-api`)
- ✅ Artifacts download successfully

## Step 6: Debugging Common Issues

### CI Workflow Issues

**Problem: Build fails with path errors**
- **Check:** `build` job logs
- **Look for:** References to old PascalCase paths (`EchoAPI`, `Shared`)
- **Fix:** Ensure all configuration files use kebab-case

**Problem: Matrix shows wrong project names**
- **Check:** `detect-changes` job output
- **Look for:** PowerShell script output
- **Fix:** Verify deployment config and project.json files

### CD Workflow Issues

**Problem: Artifact download fails**
- **Check:** `download-artifacts` job
- **Look for:** "Artifact not found" errors
- **Fix:** Verify artifact names match between CI and CD

**Problem: Matrix generation fails**
- **Check:** `determine-changes` job
- **Look for:** JSON parsing errors
- **Fix:** Verify PowerShell script outputs valid JSON

**Problem: Path errors in deployment**
- **Check:** `deploy-staging` job
- **Look for:** References to old paths
- **Fix:** Ensure all workflow files use kebab-case paths

### Common Error Messages

```
❌ Artifact not found: echo-api-build-artifacts
```
- **Cause:** CI didn't upload artifacts or name mismatch
- **Solution:** Check CI workflow artifacts section

```
❌ Matrix JSON is invalid
```
- **Cause:** PowerShell script output malformed
- **Solution:** Check `determine-changes` job logs

```
❌ Path not found: apps/EchoAPI
```
- **Cause:** Old PascalCase path reference
- **Solution:** Update to `apps/echo-api`

## Step 7: Verify Final Results

### Successful Run Indicators

- ✅ All jobs show green checkmarks
- ✅ No red X marks or failed steps
- ✅ Artifacts are downloaded successfully
- ✅ Deployment notification shows success

### What Success Looks Like

```
✅ load-config
✅ determine-changes  
✅ consolidate-deployment
✅ download-artifacts
✅ prepare-artifacts
✅ deploy-staging
✅ deployment-summary
```

### Final Artifacts to Check

1. **Go to any completed CD workflow run**
2. **Scroll down to "Artifacts" section**
3. **Verify you see:**
   - `echo-api-deployment-artifacts`
   - `echo-api-final-artifacts`

## Step 8: Clean Up

After successful testing:

```bash
# Revert test changes if needed
git checkout -- README.md
git commit -m "revert: remove test changes"
git push origin main
```

## Troubleshooting Checklist

- [ ] All project.json files use kebab-case paths
- [ ] Deployment config uses kebab-case paths
- [ ] Solution file references kebab-case paths
- [ ] Workflow files use kebab-case paths
- [ ] PowerShell script outputs valid JSON
- [ ] Artifact names match between CI and CD
- [ ] Nx projects are detected correctly
- [ ] .NET solution builds successfully

## Next Steps

After successful workflow testing:

1. **Document any issues found** and their solutions
2. **Update team documentation** if needed
3. **Consider adding automated tests** for workflow validation
4. **Set up monitoring** for workflow failures

---

**Note:** This guide assumes the repository uses kebab-case naming convention (`echo-api`, `shared`) as implemented in the recent refactoring. 