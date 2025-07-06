# CI/CD Strategy

## Overview

Our CI/CD pipeline uses GitHub Actions with Nx for efficient monorepo management. The system automatically detects changes, builds only affected projects, and deploys to appropriate environments.

## Key Principles

### 1. Incremental Processing
- **Only build what changed**: Uses Nx affected detection to identify impacted projects
- **Parallel execution**: Independent projects build simultaneously
- **Smart caching**: NuGet packages, Nx cache, and build artifacts are cached

### 2. Configuration-Driven
- **Centralized config**: All settings in `.github/config/` files
- **Environment-specific**: Different settings per deployment environment
- **Reusable components**: Shared actions and scripts

### 3. Quality Gates
- **PR validation**: Early feedback on code quality
- **Automated testing**: Unit tests with coverage reporting
- **Security scanning**: Dependency vulnerability checks

## Pipeline Flow

### Development → Production

```
Local Changes → PR → Validation → CI Build → CD Deploy → Staging → Production
     ↓           ↓        ↓         ↓         ↓         ↓         ↓
   Nx Graph   PR Checks  Build    Test     Artifacts  Auto     Manual
   Affected   & Lint     Matrix   Coverage  Upload    Deploy   Approval
```

### Change Detection Logic

**Library Changes**:
```
Change: libs/Shared/EchoService.cs
Affected: Shared + EchoAPI (depends on Shared)
Build: Both projects
Deploy: EchoAPI only
```

**App Changes**:
```
Change: apps/EchoAPI/Program.cs
Affected: EchoAPI only
Build: EchoAPI only
Deploy: EchoAPI only
```

**Documentation Changes**:
```
Change: README.md
Affected: None
Build: Skip
Deploy: Skip
```

## Configuration Files

### Workflow Configuration (`.github/config/workflow-config.yml`)
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

### Deployment Configuration (`.github/config/deployment-config.json`)
```json
{
  "apps": {
    "echo-api": {
      "type": "webapi",
      "path": "apps/EchoAPI",
      "environments": ["dev", "staging", "prod"],
      "deployment": {
        "type": "azure-app-service"
      }
    }
  },
  "libs": {
    "shared": {
      "type": "classlib",
      "path": "libs/Shared",
      "publish": false
    }
  }
}
```

## Workflows

### 1. PR Validation (`pr.yml`)
**Triggers**: Pull request creation/update
**Purpose**: Early quality feedback

**Checks**:
- Semantic PR title validation
- Merge conflict detection
- Dependency vulnerability scanning
- Code quality checks (Nx linting)
- PR size warnings

### 2. Continuous Integration (`ci.yml`)
**Triggers**: Push to main/develop, PR updates
**Purpose**: Build and test affected projects

**Process**:
1. **Change Detection**: PowerShell script identifies affected projects
2. **Parallel Builds**: Matrix strategy builds projects simultaneously
3. **Testing**: Run tests with coverage collection
4. **Artifacts**: Upload build outputs for deployment

### 3. Continuous Deployment (`cd.yml`)
**Triggers**: Successful CI on main, manual dispatch
**Purpose**: Deploy to environments

**Flow**:
1. Determine changed applications
2. Download build artifacts
3. Deploy to target environment
4. Run health checks

## Efficiency Features

### Caching Strategy
- **NuGet Cache**: Global package caching across workflows
- **Nx Cache**: Build output caching with cross-workflow persistence
- **Node Modules**: Dependencies cached for faster setup

### Parallel Execution
- **Project-Level Parallel**: Independent projects build simultaneously
- **Matrix Strategy**: GitHub Actions matrix for multiple projects
- **Dependency-Aware**: Ensures proper build ordering

### Incremental Processing
- **Affected Projects Only**: Processes only changed projects
- **Smart Test Selection**: Runs tests based on change scope
- **Conditional Deployment**: Deploys only when necessary

## Environment Strategy

### Staging
- **Automatic deployment**: No approval required
- **Purpose**: Integration testing, pre-production validation
- **Access**: Development team

### Production
- **Manual approval**: Environment protection rules
- **Purpose**: Live application
- **Access**: Operations team

## Monitoring & Visibility

### Pipeline Status
- **Workflow summaries**: Comprehensive status reports
- **Job status tracking**: Clear success/failure indicators
- **Artifact management**: Build artifact tracking
- **Deployment status**: Environment-specific deployment tracking

### Health Checks
- **Post-deployment validation**: Automated health checks
- **Rollback capability**: Quick rollback mechanisms
- **Performance monitoring**: Build time tracking

## Developer Workflow

### Local Development
1. **Check affected projects**: `npx nx affected:graph`
2. **Local testing**: Ensure changes work before pushing
3. **Create PR**: Use semantic commit messages

### PR Process
1. **Automatic validation**: PR checks run automatically
2. **Code review**: Required before merge
3. **CI/CD pipeline**: Builds and tests affected projects

### Deployment
1. **Merge to main**: Triggers automatic staging deployment
2. **Staging validation**: Test in staging environment
3. **Production approval**: Manual approval for production deployment

## Troubleshooting

### Common Issues

**Build Failures**:
- Check Nx project configuration
- Verify dependencies are correctly referenced
- Review build logs for specific errors

**Deployment Failures**:
- Verify environment configuration
- Check artifact availability
- Review deployment logs

**Cache Issues**:
- Clear Nx cache: `npx nx reset`
- Check cache key configuration
- Verify cache persistence settings

### Debug Commands
```bash
# Check affected projects
npx nx affected:graph

# Show project configuration
npx nx show project <project-name>

# List all projects
npx nx show projects

# Clear cache
npx nx reset
```

## Best Practices

### Development
- **Small, focused changes**: Easier to review and debug
- **Semantic commits**: Use conventional commit format
- **Local testing**: Test changes before pushing

### Configuration
- **Centralized settings**: Use config files, not hardcoded values
- **Environment variables**: Use secrets for sensitive data
- **Version pinning**: Pin dependency versions for consistency

### Monitoring
- **Watch pipeline status**: Monitor workflow execution
- **Review logs**: Check detailed logs for failures
- **Performance tracking**: Monitor build and deployment times

## Related Documentation

- **Testing Strategy**: `docs/ci-pipeline-testing-strategy.md`
- **Setup Requirements**: `docs/github-setup-requirements.md`
- **Implementation Summary**: `docs/phase1-implementation-summary.md` 