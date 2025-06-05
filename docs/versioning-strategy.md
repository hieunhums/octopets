# Versioning Strategy for Octopets

## Overview

This document outlines the versioning approach for the Octopets distributed application, which consists of multiple components that need coordinated versioning and release management.

## Components

The Octopets application consists of the following components:

- **Frontend** (React + TypeScript): Web application for users
- **Backend** (ASP.NET Core): API and business logic
- **AppHost** (.NET Aspire): Application orchestration and configuration
- **ServiceDefaults**: Shared configuration and defaults

## Versioning Scheme

### Semantic Versioning (SemVer)

We follow [Semantic Versioning 2.0.0](https://semver.org/) for all components:

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILDMETADATA]
```

- **MAJOR**: Breaking changes that require user action
- **MINOR**: New features that are backward compatible
- **PATCH**: Bug fixes and maintenance updates
- **PRERELEASE**: Pre-release versions (alpha, beta, rc)
- **BUILDMETADATA**: Build information (commit hash, build number)

### Version Numbering Strategy

#### Application-Level Versioning
The entire Octopets application follows a unified version number:
- Example: `1.2.3`
- All components are released together with the same version number
- Ensures compatibility across all distributed components

#### Component-Level Versioning
Individual components may have patch-level differences:
- Frontend: `1.2.3`
- Backend: `1.2.3`  
- AppHost: `1.2.3`
- ServiceDefaults: `1.2.2` (if no changes in this release)

### Version Ranges

| Version | Type | Description | Example |
|---------|------|-------------|---------|
| 0.x.x | Development | Pre-1.0 development releases | 0.1.0, 0.2.5 |
| 1.x.x | Stable | Production-ready releases | 1.0.0, 1.5.2 |
| x.0.0 | Major | Breaking changes | 2.0.0, 3.0.0 |
| x.y.0 | Minor | New features | 1.1.0, 1.2.0 |
| x.y.z | Patch | Bug fixes | 1.1.1, 1.2.3 |

## Release Types

### Release Channels

1. **Development** (`dev`)
   - Continuous integration builds
   - Version: `0.x.x-dev.{buildnumber}`
   - Deployed to development environment

2. **Alpha** (`alpha`)
   - Feature-complete but not fully tested
   - Version: `x.y.z-alpha.{number}`
   - Internal testing only

3. **Beta** (`beta`)
   - Feature-complete and tested
   - Version: `x.y.z-beta.{number}`
   - Limited external testing

4. **Release Candidate** (`rc`)
   - Production-ready candidate
   - Version: `x.y.z-rc.{number}`
   - Final testing before release

5. **Stable** (no suffix)
   - Production release
   - Version: `x.y.z`
   - Deployed to production

### Version Examples

```bash
# Development builds
0.1.0-dev.123
0.2.0-dev.456

# Pre-release versions
1.0.0-alpha.1
1.0.0-beta.1
1.0.0-rc.1

# Stable releases
1.0.0
1.1.0
1.1.1
2.0.0
```

## Branching Strategy

### Git Flow Adaptation

```
main (production)
├── develop (integration)
├── feature/* (new features)
├── release/* (release preparation)
├── hotfix/* (emergency fixes)
└── docs/* (documentation updates)
```

### Branch-Version Mapping

| Branch | Version Pattern | Purpose |
|--------|----------------|---------|
| `main` | `x.y.z` | Production releases |
| `develop` | `x.y.z-dev.{build}` | Integration and testing |
| `feature/*` | `x.y.z-feat.{name}` | Feature development |
| `release/*` | `x.y.z-rc.{number}` | Release preparation |
| `hotfix/*` | `x.y.z+hotfix.{name}` | Emergency fixes |

## Version Management

### Configuration Files

#### Frontend (package.json)
```json
{
  "name": "octopets-frontend",
  "version": "1.0.0",
  "private": true
}
```

#### Backend (.csproj)
```xml
<PropertyGroup>
  <Version>1.0.0</Version>
  <AssemblyVersion>1.0.0.0</AssemblyVersion>
  <FileVersion>1.0.0.0</FileVersion>
</PropertyGroup>
```

#### AppHost (.csproj)
```xml
<PropertyGroup>
  <Version>1.0.0</Version>
  <AssemblyVersion>1.0.0.0</AssemblyVersion>
</PropertyGroup>
```

### Version File (version.json)
Central version configuration:

```json
{
  "version": "1.0.0",
  "components": {
    "frontend": "1.0.0",
    "backend": "1.0.0",
    "apphost": "1.0.0",
    "servicedefaults": "1.0.0"
  },
  "buildMetadata": {
    "commit": "abc123def",
    "buildNumber": "456",
    "buildDate": "2024-01-15T10:30:00Z"
  }
}
```

## Release Process

### 1. Development Phase
- Work on `develop` branch
- Version: `x.y.z-dev.{build}`
- Continuous integration builds

### 2. Feature Development
- Create feature branch: `feature/new-listing-search`
- Version: `x.y.z-feat.new-listing-search`
- Merge back to `develop` when complete

### 3. Release Preparation
- Create release branch: `release/1.2.0`
- Update version numbers in all components
- Perform final testing
- Create release candidate: `1.2.0-rc.1`

### 4. Production Release
- Merge to `main` branch
- Tag release: `v1.2.0`
- Deploy to production
- Create release notes

### 5. Hotfix Process
- Create hotfix branch: `hotfix/security-patch`
- Version: `1.2.1` (increment patch)
- Merge to both `main` and `develop`

## Compatibility Matrix

### API Versioning
- Backend API uses semantic versioning
- Breaking changes require major version bump
- Deprecation notices for minor version changes

### Frontend-Backend Compatibility
| Frontend | Backend | Compatible |
|----------|---------|------------|
| 1.x.x | 1.x.x | ✅ Full |
| 1.x.x | 1.y.x (y > x) | ✅ Forward compatible |
| 1.x.x | 2.x.x | ❌ Breaking changes |

## Automation

### CI/CD Integration
- Automatic version bumping based on commit messages
- Version validation in pull requests
- Automatic tagging for releases

### Version Scripts
```bash
# Bump version
npm run version:patch
npm run version:minor
npm run version:major

# Sync versions across components
./scripts/sync-versions.sh
```

## Migration Guidelines

### Breaking Changes (Major Version)
1. Provide migration guide
2. Support previous major version for 6 months
3. Clear deprecation timeline

### Feature Additions (Minor Version)
1. Maintain backward compatibility
2. Feature flags for gradual rollout
3. Documentation updates

### Bug Fixes (Patch Version)
1. No breaking changes
2. Immediate deployment to production
3. Hotfix process for critical issues

## Monitoring and Rollback

### Version Tracking
- Application Insights integration
- Version headers in API responses
- Frontend version display (dev mode)

### Rollback Strategy
- Previous version artifacts retained
- Blue-green deployment support
- Database migration rollback plans

## Documentation Requirements

Each release must include:
- Release notes (see template below)
- Migration guide (for breaking changes)
- API documentation updates
- Configuration changes

---

*This versioning strategy is designed to support the distributed nature of the Octopets application while maintaining simplicity and reliability.*