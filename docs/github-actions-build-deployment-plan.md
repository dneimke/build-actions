# GitHub Actions Build & Deployment Plan

## Overview

This document outlines the GitHub Actions build and deployment strategy for our .NET-based monorepo using Nx for build orchestration. The design prioritizes efficiency, reusability, and scalability to support dozens of applications and libraries.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Key Design Principles](#key-design-principles)
3. [Workflow Strategy](#workflow-strategy)
4. [Efficiency Optimizations](#efficiency-optimizations)
5. [Configuration Management](#configuration-management)
6. [Implementation Phases](#implementation-phases)
7. [Benefits](#benefits)

## Architecture Overview

### Directory Structure

```
.github/
├── workflows/
│   ├── ci.yml                    # Main CI pipeline
│   ├── cd.yml                    # Main CD pipeline  
│   ├── pr.yml                    # Pull request validation
├── actions/
│   ├── load-config/              # Reusable config loading action
│   └── setup-environment/        # Reusable environment setup
├── scripts/
│   └── get-affected-projects.ps1 # PowerShell script for Nx affected
└── config/
    ├── workflow-config.yml       # Centralized workflow configuration
    └── deployment-config.json    # Centralized deployment configuration
```

### Current Project Structure

- **Apps**: `apps/EchoAPI/` - .NET 8 Web API
- **Libraries**: `libs/Shared/` - Shared .NET class library
- **Build System**: Nx with `@nx-dotnet/core` plugin
- **Solution**: `MonoRepoSolution.sln` - Visual Studio solution file

## Key Design Principles

### Efficient Change Detection

- **Nx Affected**: Leverage Nx's built-in affected project detection
- **Incremental Builds**: Only build/test projects that have changed or depend on changed projects
- **Dependency Graph**: Use Nx's dependency graph to determine build order

### Reusable Components

- **Composite Actions**: Create reusable composite actions for common tasks
- **Configuration-Driven**: Centralize configuration in YAML and JSON files
- **Modular Design**: Separate concerns into focused, reusable components

### Per-Application Workflows

- **Dynamic Matrix**: Generate build matrices based on affected projects
- **Independent Deployment**: Each app can be deployed independently
- **Environment-Specific**: Support multiple deployment environments

## Workflow Strategy

### Pull Request Workflow

1. **Change Detection**: Use Nx to identify affected projects
2. **Parallel Builds**: Build affected projects in parallel
3. **Dependency Order**: Respect project dependencies
4. **Caching**: Cache NuGet packages and build artifacts
5. **Testing**: Run tests only for affected projects

### Main Branch Workflow

1. **Full Build**: Build all projects (for main branch)
2. **Artifact Publishing**: Publish build artifacts
3. **Deployment Triggers**: Trigger deployments based on changes
4. **Environment Promotion**: Support staging → production promotion

### Per-App Deployment

1. **App-Specific Triggers**: Deploy only when specific apps change
2. **Environment Matrix**: Support multiple environments per app
3. **Rollback Capability**: Include rollback mechanisms
4. **Health Checks**: Post-deployment validation

## Efficiency Optimizations

### Caching Strategy

- **NuGet Cache**: Cache NuGet packages globally
- **Build Cache**: Cache build outputs per project
- **Docker Layer Cache**: For containerized deployments
- **Nx Cache**: Leverage Nx's built-in caching

### Parallelization

- **Project-Level Parallel**: Build independent projects in parallel
- **Matrix Strategy**: Use GitHub's matrix strategy for multiple apps
- **Dependency-Aware**: Ensure dependencies are built first

### Incremental Processing

- **Affected Projects Only**: Only process changed projects
- **Smart Test Selection**: Run tests based on change scope
- **Conditional Deployment**: Deploy only when necessary

## Configuration Management

### Centralized Configuration

**`.github/config/workflow-config.yml`**:
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

**`.github/config/deployment-config.json`**:
```json
{
  "apps": {
    "echo-api": {
      "type": "webapi",
      "path": "apps/EchoAPI",
      "environments": ["dev", "staging", "prod"],
      "deployment": {
        "type": "azure-app-service",
        "resourceGroup": "my-rg",
        "appServiceName": "echo-api"
      },
      "build": {
        "framework": "net8.0",
        "publish": true,
        "test": true
      }
    }
  },
  "libs": {
    "shared": {
      "type": "classlib",
      "path": "libs/Shared",
      "publish": false,
      "build": {
        "framework": "net8.0",
        "test": false
      }
    }
  }
}
```

### Environment-Specific Settings

- **Secrets Management**: Use GitHub Secrets for sensitive data
- **Environment Variables**: Configure per environment
- **Feature Flags**: Support feature toggle deployment

## Implementation Phases

### Phase 1: Foundation ✅

1. **Set up basic CI/CD workflows**
   - ✅ Create main CI workflow with Nx affected detection
   - ✅ Implement basic build and test steps
   - ✅ Set up pull request validation

2. **Implement Nx affected detection**
   - ✅ Create PowerShell script to get affected projects
   - ✅ Integrate with GitHub Actions matrix strategy
   - ✅ Handle dependency ordering

3. **Create reusable components**
   - ✅ Load-config composite action
   - ✅ Setup-environment composite action
   - ✅ Centralized configuration files

4. **Establish caching strategy**
   - ✅ Configure NuGet package caching
   - ✅ Set up build artifact caching
   - ✅ Implement Nx cache persistence

### Phase 2: Optimization

1. **Implement parallel builds**
   - Optimize matrix strategy for maximum parallelism
   - Ensure dependency-aware execution
   - Monitor and optimize build times

2. **Add comprehensive testing**
   - Unit tests for all projects
   - Integration tests for APIs
   - Code coverage reporting

3. **Optimize build times**
   - Analyze build bottlenecks
   - Implement incremental builds
   - Optimize Docker layer caching

4. **Add artifact management**
   - Publish build artifacts
   - Version management
   - Artifact retention policies

### Phase 3: Advanced Features

1. **Multi-environment deployment**
   - Dev, staging, and production environments
   - Environment-specific configurations
   - Blue-green deployment support

2. **Rollback mechanisms**
   - Automated rollback triggers
   - Health check integration
   - Rollback notifications

3. **Monitoring integration**
   - Deployment monitoring
   - Performance metrics
   - Error tracking

4. **Advanced caching**
   - Cross-workflow caching
   - Cache invalidation strategies
   - Cache performance monitoring

## Benefits

### Scalability
- Can handle dozens of apps and libs efficiently
- Horizontal scaling through parallel execution
- Vertical scaling through optimized resource usage

### Maintainability
- Reusable components reduce duplication
- Centralized configuration management
- Clear separation of concerns

### Performance
- Only builds what's necessary
- Efficient caching strategies
- Parallel execution where possible

### Flexibility
- Supports different deployment strategies per app
- Environment-specific configurations
- Easy to extend and modify

### Reliability
- Proper dependency management
- Comprehensive testing strategy
- Rollback capabilities

## Next Steps

1. **Review and approve this plan**
2. **Prioritize implementation phases**
3. **Set up initial GitHub Actions workflows**
4. **Implement Phase 1 components**
5. **Iterate and optimize based on real-world usage**

## Technical Considerations

### Nx Integration
- Leverage `@nx-dotnet/core` plugin capabilities
- Use Nx's dependency graph for build ordering
- Implement Nx cache for build acceleration

### .NET Specific Optimizations
- NuGet package caching
- MSBuild incremental builds
- .NET-specific test runners

### GitHub Actions Best Practices
- Use reusable workflows
- Implement proper secret management
- Follow security best practices
- Optimize for GitHub-hosted runners

---

*This document should be updated as the implementation progresses and new requirements are identified.* 