# GitHub Actions Setup

This directory contains the GitHub Actions workflows and configuration for our .NET monorepo.

## Overview

Our CI/CD pipeline is designed to be efficient, scalable, and maintainable. It uses Nx for intelligent change detection and builds only what's necessary.

## Directory Structure

```
.github/
├── workflows/
│   ├── ci.yml                    # Main CI pipeline
│   ├── cd.yml                    # Main CD pipeline  
│   ├── pr.yml                    # Pull request validation
│   └── templates/
│       ├── build-dotnet.yml      # Reusable .NET build template
│       ├── test-dotnet.yml       # Reusable .NET test template
│       └── deploy-app.yml        # Reusable app deployment template
├── scripts/
│   └── get-affected-projects.ps1 # PowerShell script for Nx affected
└── config/
    └── deployment-config.json    # Centralized deployment configuration
```

## Workflows

### CI Pipeline (`ci.yml`)

**Triggers:** Push to main/develop, Pull requests to main/develop

**What it does:**
1. Detects affected projects using Nx
2. Builds affected projects in parallel
3. Tests affected projects in parallel
4. Generates summary reports

**Key Features:**
- Only builds/test projects that have changed
- Parallel execution for efficiency
- Comprehensive caching (NuGet, Nx)
- Artifact publishing for deployment

### CD Pipeline (`cd.yml`)

**Triggers:** Push to main, Manual dispatch

**What it does:**
1. Determines what needs to be deployed
2. Builds projects for deployment
3. Deploys to staging (automatic)
4. Deploys to production (manual approval)

**Key Features:**
- Environment-specific deployments
- Manual approval for production
- Health checks after deployment
- Support for multiple deployment types

### Pull Request Validation (`pr.yml`)

**Triggers:** Pull request events

**What it does:**
1. Validates PR title format
2. Checks for merge conflicts
3. Runs security scans (CodeQL)
4. Checks for vulnerable dependencies
5. Runs code quality checks
6. Warns about large PRs

## Templates

### Build Template (`build-dotnet.yml`)

Reusable workflow for building .NET projects.

**Inputs:**
- `project-name`: Name of the project
- `project-path`: Path to project directory
- `project-type`: Type of project (webapi, classlib, etc.)
- `dotnet-version`: .NET version to use
- `build-configuration`: Build configuration (Debug/Release)
- `publish`: Whether to publish the project

**Outputs:**
- `build-success`: Whether build was successful
- `artifacts-path`: Path to build artifacts

### Test Template (`test-dotnet.yml`)

Reusable workflow for testing .NET projects.

**Inputs:**
- `project-name`: Name of the project
- `project-path`: Path to project directory
- `dotnet-version`: .NET version to use
- `test-framework`: Test framework to use
- `collect-coverage`: Whether to collect code coverage

**Outputs:**
- `test-success`: Whether tests passed
- `coverage-path`: Path to coverage reports

### Deploy Template (`deploy-app.yml`)

Reusable workflow for deploying applications.

**Inputs:**
- `app-name`: Name of the application
- `app-path`: Path to application directory
- `environment`: Environment to deploy to
- `deployment-type`: Type of deployment
- `artifacts-name`: Name of artifacts to download

## Configuration

### Deployment Configuration (`deployment-config.json`)

Centralized configuration for all apps and libraries.

```json
{
  "apps": {
    "EchoAPI": {
      "type": "webapi",
      "path": "apps/EchoAPI",
      "environments": ["dev", "staging", "prod"],
      "deployment": {
        "type": "azure-app-service",
        "resourceGroup": "my-rg",
        "appServiceName": "echo-api"
      }
    }
  },
  "libs": {
    "Shared": {
      "type": "classlib",
      "path": "libs/Shared",
      "publish": false
    }
  }
}
```

## Scripts

### Get Affected Projects (`get-affected-projects.ps1`)

PowerShell script that uses Nx to detect affected projects and generates a matrix for GitHub Actions.

**Usage:**
```powershell
pwsh .github/scripts/get-affected-projects.ps1 -BaseBranch main -HeadBranch HEAD
```

**Outputs:**
- `has-changes`: Whether any projects were affected
- `matrix`: JSON matrix for GitHub Actions
- `affected-projects`: Comma-separated list of affected projects

## Caching Strategy

### NuGet Cache
- Caches `~/.nuget/packages`
- Key: `{runner.os}-nuget-{hash of .csproj files}`
- Restore keys for partial cache hits

### Nx Cache
- Caches `.nx/cache`
- Key: `{runner.os}-nx-{hash of nx.json}`
- Persists across workflows

### Node Modules Cache
- Caches `node_modules`
- Uses GitHub's built-in npm cache action

## Environment Variables

### Required Secrets
- `AZURE_CREDENTIALS`: Azure service principal credentials
- `AZURE_WEBAPP_PUBLISH_PROFILE`: Azure App Service publish profile

### Optional Secrets
- `DOCKER_USERNAME`: Docker registry username
- `DOCKER_PASSWORD`: Docker registry password

## Adding New Projects

1. **Add to configuration:**
   Update `.github/config/deployment-config.json` with new project details.

2. **Update Nx configuration:**
   Ensure the project is properly configured in `nx.json`.

3. **Add deployment secrets:**
   If deploying to new environments, add required secrets to GitHub.

## Troubleshooting

### Common Issues

1. **Nx affected detection not working:**
   - Ensure `fetch-depth: 0` is set in checkout action
   - Check that Nx is properly configured

2. **Build failures:**
   - Check project dependencies in `.csproj` files
   - Verify .NET version compatibility

3. **Deployment failures:**
   - Verify Azure credentials and permissions
   - Check environment-specific configuration

### Debugging

1. **Enable debug logging:**
   Set `ACTIONS_STEP_DEBUG=true` in repository secrets

2. **Check workflow logs:**
   - Go to Actions tab in GitHub
   - Click on failed workflow run
   - Review job and step logs

3. **Test locally:**
   - Use `npx nx affected:graph` to test change detection
   - Use `npx nx build <project>` to test builds

## Best Practices

1. **Keep PRs focused:** Small, focused PRs build faster and are easier to review
2. **Use semantic commits:** Follow conventional commit format for better automation
3. **Monitor build times:** Regularly review and optimize slow builds
4. **Update dependencies:** Keep .NET and package versions up to date
5. **Test locally:** Always test changes locally before pushing

## Future Enhancements

- [ ] Add performance testing
- [ ] Implement blue-green deployments
- [ ] Add monitoring integration
- [ ] Support for more deployment targets
- [ ] Advanced caching strategies 