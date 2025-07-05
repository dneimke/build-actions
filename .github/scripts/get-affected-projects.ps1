#!/usr/bin/env pwsh

param(
    [string]$BaseBranch = "main",
    [string]$HeadBranch = "HEAD"
)

# Function to write output for GitHub Actions
function Write-GitHubOutput {
    param(
        [string]$Name,
        [string]$Value
    )
    Write-Output "$Name=$Value" >> $env:GITHUB_OUTPUT
}

# Function to get affected projects using Nx
function Get-AffectedProjects {
    param(
        [string]$BaseBranch,
        [string]$HeadBranch
    )
    
    try {
        # Check if Nx is available
        $nxVersion = npx nx --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Nx is not available. Please ensure Node.js dependencies are installed."
            Write-Host "Run 'npm install' to install dependencies."
            return @()
        }
        
        Write-Host "Nx version: $nxVersion"
        
        # Get affected projects using Nx
        Write-Host "Running: npx nx show projects --affected --base=$BaseBranch --head=$HeadBranch --json"
        $affectedOutput = npx nx show projects --affected --base=$BaseBranch --head=$HeadBranch --json 2>&1
        
        Write-Host "Nx output: $affectedOutput"
        Write-Host "Exit code: $LASTEXITCODE"
        
        if ($LASTEXITCODE -eq 0 -and $affectedOutput) {
            $affectedProjects = $affectedOutput | ConvertFrom-Json
            return $affectedProjects
        } else {
            Write-Host "No affected projects found or Nx command failed"
            return @()
        }
    }
    catch {
        Write-Host "Error getting affected projects: $_"
        return @()
    }
}

# Function to get project dependencies
function Get-ProjectDependencies {
    param(
        [string]$ProjectName
    )
    
    try {
        $depsOutput = npx nx graph --file=temp-graph.json --focus=$ProjectName 2>$null
        if (Test-Path "temp-graph.json") {
            $graph = Get-Content "temp-graph.json" | ConvertFrom-Json
            Remove-Item "temp-graph.json" -Force
            return $graph.dependencies.$ProjectName
        }
    }
    catch {
        Write-Host "Error getting dependencies for $ProjectName : $_"
    }
    return @()
}

# Function to build project matrix
function Build-ProjectMatrix {
    param(
        [array]$Projects
    )
    
    $matrix = @{
        include = @()
    }
    
    foreach ($project in $Projects) {
        $projectInfo = @{
            name = $project
            path = Get-ProjectPath -ProjectName $project
            type = Get-ProjectType -ProjectName $project
        }
        
        $matrix.include += $projectInfo
    }
    
    return $matrix
}

# Function to get project path from configuration
function Get-ProjectPath {
    param(
        [string]$ProjectName
    )
    
    $configPath = ".github/config/deployment-config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        
        if ($config.apps.$ProjectName) {
            return $config.apps.$ProjectName.path
        }
        elseif ($config.libs.$ProjectName) {
            return $config.libs.$ProjectName.path
        }
    }
    
    # Fallback to common patterns
    if (Test-Path "apps/$ProjectName") {
        return "apps/$ProjectName"
    }
    elseif (Test-Path "libs/$ProjectName") {
        return "libs/$ProjectName"
    }
    
    return $ProjectName
}

# Function to get project type from configuration
function Get-ProjectType {
    param(
        [string]$ProjectName
    )
    
    $configPath = ".github/config/deployment-config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        
        if ($config.apps.$ProjectName) {
            return $config.apps.$ProjectName.type
        }
        elseif ($config.libs.$ProjectName) {
            return $config.libs.$ProjectName.type
        }
    }
    
    return "unknown"
}

# Main execution
Write-Host "Getting affected projects from $BaseBranch to $HeadBranch..."

$affectedProjects = Get-AffectedProjects -BaseBranch $BaseBranch -HeadBranch $HeadBranch

if ($affectedProjects.Count -eq 0) {
    Write-Host "No affected projects found"
    Write-GitHubOutput -Name "has-changes" -Value "false"
    Write-GitHubOutput -Name "matrix" -Value '{"include":[]}'
    exit 0
}

Write-Host "Affected projects: $($affectedProjects -join ', ')"

# Build matrix for GitHub Actions
$matrix = Build-ProjectMatrix -Projects $affectedProjects
$matrixJson = $matrix | ConvertTo-Json -Depth 10 -Compress

Write-GitHubOutput -Name "has-changes" -Value "true"
Write-GitHubOutput -Name "matrix" -Value $matrixJson
Write-GitHubOutput -Name "affected-projects" -Value ($affectedProjects -join ',')

Write-Host "Matrix generated: $matrixJson" 