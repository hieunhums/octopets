# Version Management Guide

## Overview

This guide provides practical instructions for managing versions across the Octopets distributed application. It includes step-by-step procedures, automation scripts, and best practices.

## Quick Reference

### Current Version Information
```bash
# Check current versions
cat version.json

# Frontend version
cd frontend && npm version

# Backend version
grep -r "Version>" backend/*.csproj

# Git tags
git tag --list --sort=-version:refname
```

### Version Bump Commands
```bash
# Patch release (bug fixes)
./scripts/bump-version.sh patch

# Minor release (new features)
./scripts/bump-version.sh minor

# Major release (breaking changes)
./scripts/bump-version.sh major
```

## Version File Management

### Central Version Configuration

Create and maintain `version.json` in the repository root:

```json
{
  "version": "1.0.0",
  "releaseDate": "2024-01-15",
  "releaseName": "Initial Release",
  "components": {
    "frontend": "1.0.0",
    "backend": "1.0.0",
    "apphost": "1.0.0",
    "servicedefaults": "1.0.0"
  },
  "prerelease": null,
  "buildMetadata": {
    "commit": "",
    "buildNumber": "",
    "buildDate": ""
  },
  "compatibility": {
    "apiVersion": "1.0",
    "databaseVersion": "1.0",
    "configVersion": "1.0"
  }
}
```

### Component Version Files

#### Frontend Package.json
```json
{
  "name": "octopets-frontend",
  "version": "1.0.0",
  "description": "Octopets frontend application",
  "private": true
}
```

#### Backend Project Files
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <Version>1.0.0</Version>
    <AssemblyVersion>1.0.0.0</AssemblyVersion>
    <FileVersion>1.0.0.0</FileVersion>
    <InformationalVersion>1.0.0</InformationalVersion>
  </PropertyGroup>
</Project>
```

## Release Workflows

### 1. Development Release Workflow

```bash
# 1. Start development cycle
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/new-search-functionality

# 3. Development work...
# ... commit changes ...

# 4. Prepare for merge
./scripts/update-dev-version.sh

# 5. Create pull request to develop
git push origin feature/new-search-functionality
```

### 2. Stable Release Workflow

```bash
# 1. Create release branch
git checkout develop
git checkout -b release/1.2.0

# 2. Update versions
./scripts/bump-version.sh minor
git add .
git commit -m "Bump version to 1.2.0"

# 3. Create release candidate
./scripts/create-release-candidate.sh

# 4. Testing and bug fixes...
./scripts/bump-version.sh rc

# 5. Final release
git checkout main
git merge release/1.2.0
git tag v1.2.0
git push origin main --tags

# 6. Update develop
git checkout develop
git merge main
```

### 3. Hotfix Workflow

```bash
# 1. Create hotfix branch
git checkout main
git checkout -b hotfix/security-patch

# 2. Apply fix and bump patch version
./scripts/bump-version.sh patch
git add .
git commit -m "Fix: Critical security patch"

# 3. Merge to main
git checkout main
git merge hotfix/security-patch
git tag v1.2.1
git push origin main --tags

# 4. Merge to develop
git checkout develop
git merge main
```

## Automation Scripts

### Version Bump Script (`scripts/bump-version.sh`)

```bash
#!/bin/bash

# Usage: ./scripts/bump-version.sh [major|minor|patch|rc|beta|alpha]

VERSION_TYPE=$1
CURRENT_VERSION=$(jq -r '.version' version.json)

case $VERSION_TYPE in
  major)
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print ($1+1)".0.0"}')
    ;;
  minor)
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."($2+1)".0"}')
    ;;
  patch)
    NEW_VERSION=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."($3+1)}')
    ;;
  rc)
    if [[ $CURRENT_VERSION == *"-rc."* ]]; then
      RC_NUM=$(echo $CURRENT_VERSION | grep -oE 'rc\.([0-9]+)' | cut -d. -f2)
      NEW_RC_NUM=$((RC_NUM + 1))
      NEW_VERSION=$(echo $CURRENT_VERSION | sed "s/rc\.$RC_NUM/rc.$NEW_RC_NUM/")
    else
      NEW_VERSION="$CURRENT_VERSION-rc.1"
    fi
    ;;
  *)
    echo "Usage: $0 [major|minor|patch|rc|beta|alpha]"
    exit 1
    ;;
esac

echo "Bumping version from $CURRENT_VERSION to $NEW_VERSION"

# Update version.json
jq --arg version "$NEW_VERSION" '.version = $version' version.json > tmp.json && mv tmp.json version.json

# Update frontend package.json
cd frontend
npm version $NEW_VERSION --no-git-tag-version
cd ..

# Update backend project files
find . -name "*.csproj" -exec sed -i "s/<Version>.*<\/Version>/<Version>$NEW_VERSION<\/Version>/g" {} \;
find . -name "*.csproj" -exec sed -i "s/<AssemblyVersion>.*<\/AssemblyVersion>/<AssemblyVersion>$NEW_VERSION.0<\/AssemblyVersion>/g" {} \;

echo "Version updated to $NEW_VERSION"
```

### Version Sync Script (`scripts/sync-versions.sh`)

```bash
#!/bin/bash

# Sync all component versions with main version

MAIN_VERSION=$(jq -r '.version' version.json)

echo "Synchronizing all components to version $MAIN_VERSION"

# Update component versions in version.json
jq --arg version "$MAIN_VERSION" '
  .components.frontend = $version |
  .components.backend = $version |
  .components.apphost = $version |
  .components.servicedefaults = $version
' version.json > tmp.json && mv tmp.json version.json

# Update frontend
cd frontend
npm version $MAIN_VERSION --no-git-tag-version
cd ..

# Update all .NET projects
find . -name "*.csproj" -exec sed -i "s/<Version>.*<\/Version>/<Version>$MAIN_VERSION<\/Version>/g" {} \;

echo "All components synchronized to version $MAIN_VERSION"
```

### Pre-release Script (`scripts/create-prerelease.sh`)

```bash
#!/bin/bash

# Create pre-release version
# Usage: ./scripts/create-prerelease.sh [alpha|beta|rc]

PRERELEASE_TYPE=$1
CURRENT_VERSION=$(jq -r '.version' version.json)
BUILD_NUMBER=${GITHUB_RUN_NUMBER:-$(date +%s)}

case $PRERELEASE_TYPE in
  alpha)
    NEW_VERSION="$CURRENT_VERSION-alpha.1"
    ;;
  beta)
    NEW_VERSION="$CURRENT_VERSION-beta.1"
    ;;
  rc)
    NEW_VERSION="$CURRENT_VERSION-rc.1"
    ;;
  *)
    echo "Usage: $0 [alpha|beta|rc]"
    exit 1
    ;;
esac

echo "Creating pre-release version $NEW_VERSION"

# Update version.json with prerelease info
jq --arg version "$NEW_VERSION" --arg prerelease "$PRERELEASE_TYPE" '
  .version = $version |
  .prerelease = $prerelease |
  .buildMetadata.buildNumber = "'$BUILD_NUMBER'" |
  .buildMetadata.buildDate = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
' version.json > tmp.json && mv tmp.json version.json

./scripts/sync-versions.sh

echo "Pre-release $NEW_VERSION created"
```

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Version Management

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  version-check:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Validate version consistency
      run: |
        ./scripts/validate-versions.sh
    
    - name: Auto-bump development version
      if: github.ref == 'refs/heads/develop'
      run: |
        ./scripts/update-dev-version.sh
        
  release:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Create release tag
      run: |
        VERSION=$(jq -r '.version' version.json)
        git tag "v$VERSION"
        git push origin "v$VERSION"
```

### Version Validation Script (`scripts/validate-versions.sh`)

```bash
#!/bin/bash

# Validate version consistency across all components

MAIN_VERSION=$(jq -r '.version' version.json)
FRONTEND_VERSION=$(jq -r '.version' frontend/package.json)

# Check frontend version
if [ "$MAIN_VERSION" != "$FRONTEND_VERSION" ]; then
  echo "ERROR: Frontend version ($FRONTEND_VERSION) doesn't match main version ($MAIN_VERSION)"
  exit 1
fi

# Check backend versions
BACKEND_VERSIONS=$(grep -r "<Version>" backend/*.csproj | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
for version in $BACKEND_VERSIONS; do
  if [ "$MAIN_VERSION" != "$version" ]; then
    echo "ERROR: Backend version ($version) doesn't match main version ($MAIN_VERSION)"
    exit 1
  fi
done

echo "✅ All versions are consistent"
```

## Version Display

### Frontend Version Display

Add version information to the frontend:

```typescript
// src/config/version.ts
export const APP_VERSION = process.env.REACT_APP_VERSION || '0.0.0';
export const BUILD_DATE = process.env.REACT_APP_BUILD_DATE || '';
export const COMMIT_HASH = process.env.REACT_APP_COMMIT_HASH || '';

// src/components/VersionInfo.tsx
import React from 'react';
import { APP_VERSION, BUILD_DATE, COMMIT_HASH } from '../config/version';

export const VersionInfo: React.FC = () => {
  if (process.env.NODE_ENV !== 'development') return null;
  
  return (
    <div className="version-info">
      <small>
        Version: {APP_VERSION} | 
        Build: {BUILD_DATE} | 
        Commit: {COMMIT_HASH.substring(0, 7)}
      </small>
    </div>
  );
};
```

### Backend Version API

```csharp
// Controllers/VersionController.cs
[ApiController]
[Route("api/[controller]")]
public class VersionController : ControllerBase
{
    [HttpGet]
    public ActionResult<object> GetVersion()
    {
        var assembly = Assembly.GetExecutingAssembly();
        var version = assembly.GetName().Version;
        var informationalVersion = assembly
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
            ?.InformationalVersion;

        return Ok(new
        {
            Version = informationalVersion ?? version?.ToString(),
            AssemblyVersion = version?.ToString(),
            BuildDate = File.GetCreationTime(assembly.Location),
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")
        });
    }
}
```

## Troubleshooting

### Common Issues

#### Version Mismatch
**Problem**: Component versions don't match
**Solution**: Run `./scripts/sync-versions.sh`

#### Build Failures
**Problem**: Version format is invalid
**Solution**: Validate version format with `./scripts/validate-versions.sh`

#### Git Tag Conflicts
**Problem**: Tag already exists
**Solution**: 
```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

### Recovery Procedures

#### Rollback Version
```bash
# Rollback to previous version
git checkout main
git reset --hard HEAD~1
./scripts/sync-versions.sh
```

#### Fix Version Corruption
```bash
# Reset all versions to match git tag
LATEST_TAG=$(git describe --tags --abbrev=0)
VERSION=${LATEST_TAG#v}

jq --arg version "$VERSION" '.version = $version' version.json > tmp.json && mv tmp.json version.json
./scripts/sync-versions.sh
```

## Best Practices

### 1. Version Consistency
- Always use the central `version.json` as source of truth
- Sync all components before creating releases
- Validate versions in CI/CD pipeline

### 2. Release Planning
- Plan major releases carefully
- Maintain backward compatibility within major versions
- Communicate breaking changes clearly

### 3. Automation
- Automate version bumping
- Use scripts for consistency
- Validate in CI/CD pipeline

### 4. Documentation
- Update release notes with every version
- Maintain migration guides
- Document API changes

---

*This guide ensures consistent and reliable version management across the entire Octopets application.*