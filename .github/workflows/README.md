# GitHub Actions Workflows

This directory contains the GitHub Actions workflows for the build-actions project. The workflows have been refactored to improve reuse and simplify maintenance.

## Structure

### Main Workflows
- **`ci.yml`** - Continuous Integration workflow for building and testing
- **`pr.yml`** - Pull Request validation workflow
- **`cd.yml`** - Continuous Deployment workflow

### Templates
- **`templates/build-dotnet.yml`** - Reusable template for building .NET projects
- **`templates/test-dotnet.yml`** - Reusable template for testing .NET projects
- **`templates/deploy-app.yml`** - Reusable template for deploying applications
- **`templates/detect-changes.yml`** - Reusable template for detecting affected projects
- **`templates/generate-summary.yml`** - Reusable template for generating workflow summaries

### Custom Actions
- **`actions/setup-environment/`** - Custom action for setting up Node.js, .NET, and dependencies

### Configuration
- **`config/workflow-config.yml`** - Centralized configuration for common values

## Key Improvements

### 1. Consolidated Setup Logic
- All workflows now use the `setup-environment` custom action
- Eliminated duplication of setup steps across templates
- Consistent environment setup across all workflows

### 2. Reusable Templates
- **`detect-changes.yml`**: Eliminates duplication between CI and CD workflows
- **`generate-summary.yml`**: Standardizes summary generation across all workflows
- Templates can be easily reused in new workflows

### 3. Simplified Main Workflows
- CI workflow now uses `detect-changes` template
- CD workflow handles both automatic and manual deployments efficiently
- PR workflow uses standardized summary generation

## Usage

### Adding a New Workflow
1. Use existing templates where possible
2. Reference the configuration file for common values
3. Use the `setup-environment` action for environment setup

### Modifying Setup Logic
1. Update the `setup-environment` action
2. All workflows will automatically use the updated setup

### Adding New Templates
1. Create the template in the `templates/` directory
2. Document the inputs and outputs
3. Update this README

## Configuration

The `config/workflow-config.yml` file centralizes common configuration values:

```yaml
dotnet:
  version: '8.0.x'
  build-configuration: 'Release'

node:
  version: '18'

artifacts:
  retention-days: 7

deployment:
  health-check-delay: 30
  environments:
    staging: 'staging'
    production: 'production'
```

## Maintenance

### Common Changes
- **Update .NET version**: Change in `workflow-config.yml`
- **Update Node.js version**: Change in `workflow-config.yml` and `setup-environment` action
- **Update artifact retention**: Change in `workflow-config.yml`

### Adding New Projects
- Update the PowerShell script `scripts/get-affected-projects.ps1` if needed
- Ensure project configuration is in the deployment config

## Benefits

1. **Reduced Maintenance**: Changes to setup logic only need to be made in one place
2. **Consistency**: All workflows use the same patterns and configurations
3. **Easier Debugging**: Standardized structure makes issues easier to identify
4. **Faster Development**: New workflows can leverage existing templates
5. **Better Reliability**: Centralized configuration reduces the chance of inconsistencies 