# Versioning Approach for Octopets

This directory contains templates and tools for managing versions across the Octopets distributed application.

## 📁 Files Overview

### Documentation Templates
- **[versioning-strategy.md](versioning-strategy.md)** - Comprehensive versioning strategy and guidelines
- **[release-notes-template.md](release-notes-template.md)** - Template for creating consistent release notes
- **[version-management-guide.md](version-management-guide.md)** - Practical guide for version management tasks

### Configuration Files
- **[../version.json](../version.json)** - Central version configuration file
- **[../scripts/](../scripts/)** - Automation scripts for version management

## 🚀 Quick Start

### 1. Check Current Version
```bash
# View current version information
cat version.json

# Validate version consistency
./scripts/validate-versions.sh
```

### 2. Bump Version
```bash
# Patch release (bug fixes)
./scripts/bump-version.sh patch

# Minor release (new features)  
./scripts/bump-version.sh minor

# Major release (breaking changes)
./scripts/bump-version.sh major

# Pre-release versions
./scripts/bump-version.sh rc      # Release candidate
./scripts/bump-version.sh beta    # Beta version
./scripts/bump-version.sh alpha   # Alpha version
```

### 3. Synchronize Versions
```bash
# Sync all component versions with main version
./scripts/sync-versions.sh
```

### 4. Validate Changes
```bash
# Ensure all versions are consistent
./scripts/validate-versions.sh
```

## 📋 Version Format

Octopets follows [Semantic Versioning (SemVer)](https://semver.org/):

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILDMETADATA]
```

### Examples
- `1.0.0` - Stable release
- `1.1.0` - Minor feature release
- `1.0.1` - Patch/bug fix release
- `2.0.0` - Major release with breaking changes
- `1.0.0-rc.1` - Release candidate
- `1.0.0-beta.2` - Beta version
- `1.0.0-alpha.1` - Alpha version

## 🏗️ Application Components

The Octopets application consists of multiple components that are versioned together:

| Component | Description | Location |
|-----------|-------------|----------|
| Frontend | React + TypeScript web app | `/frontend/` |
| Backend | ASP.NET Core API | `/backend/` |
| AppHost | .NET Aspire orchestration | `/apphost/` |
| ServiceDefaults | Shared configuration | `/servicedefaults/` |

## 📊 Version Tracking

### Central Configuration (`version.json`)
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
  }
}
```

### Component Files
- **Frontend**: `frontend/package.json`
- **Backend**: Version properties in `.csproj` files
- **Git Tags**: `v1.0.0` format for releases

## 🔄 Release Workflow

### Development Release
1. Work on `develop` branch
2. Version format: `x.y.z-dev.{build}`
3. Continuous integration builds

### Feature Development  
1. Create feature branch: `feature/feature-name`
2. Version format: `x.y.z-feat.{name}`
3. Merge back to `develop`

### Stable Release
1. Create release branch: `release/x.y.z`
2. Update versions: `./scripts/bump-version.sh minor`
3. Testing and bug fixes
4. Merge to `main` and tag: `git tag vx.y.z`

### Hotfix
1. Create hotfix branch: `hotfix/fix-name`
2. Apply fix: `./scripts/bump-version.sh patch`
3. Merge to both `main` and `develop`

## 🛠️ Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `bump-version.sh` | Increment version numbers | `./scripts/bump-version.sh [major\|minor\|patch\|rc\|beta\|alpha]` |
| `sync-versions.sh` | Synchronize all component versions | `./scripts/sync-versions.sh` |
| `validate-versions.sh` | Check version consistency | `./scripts/validate-versions.sh` |

### Script Features
- ✅ Automatic version validation
- ✅ Multi-component synchronization
- ✅ SemVer compliance checking
- ✅ Git integration
- ✅ Colorized output
- ✅ Error handling and recovery

## 📚 Release Documentation

### Required for Each Release
- [ ] Release notes (use template)
- [ ] Version bump and sync
- [ ] Git tag creation
- [ ] Changelog updates
- [ ] Migration guide (if breaking changes)

### Templates Available
- **Release Notes**: Comprehensive template with all sections
- **Migration Guide**: For breaking changes
- **Changelog**: Structured change documentation

## 🔍 Best Practices

### Version Management
1. **Always validate** before committing: `./scripts/validate-versions.sh`
2. **Use central version file** as source of truth
3. **Synchronize regularly** with `./scripts/sync-versions.sh`
4. **Follow SemVer** guidelines strictly

### Release Process
1. **Plan releases** with clear scope and timeline
2. **Test thoroughly** before tagging
3. **Document changes** comprehensively
4. **Communicate breaking changes** clearly

### Automation
1. **Use provided scripts** for consistency
2. **Integrate with CI/CD** pipeline
3. **Validate in pull requests**
4. **Automate routine tasks**

## 🚨 Troubleshooting

### Common Issues

#### Version Mismatch
```bash
# Problem: Components have different versions
# Solution: Synchronize versions
./scripts/sync-versions.sh
```

#### Invalid Version Format
```bash
# Problem: Version doesn't follow SemVer
# Solution: Use bump script to ensure valid format
./scripts/bump-version.sh patch
```

#### Git Tag Conflicts
```bash
# Problem: Tag already exists
# Solution: Delete and recreate
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
git tag v1.0.0
git push origin v1.0.0
```

### Recovery Procedures
- **Rollback version**: Reset to previous git tag
- **Fix corruption**: Use sync script to restore consistency
- **Validate state**: Always run validation after fixes

## 📞 Support

### Documentation
- [Versioning Strategy](versioning-strategy.md) - Complete strategy guide
- [Release Notes Template](release-notes-template.md) - Release documentation template
- [Version Management Guide](version-management-guide.md) - Detailed management procedures

### Getting Help
- **Issues**: Create GitHub issue for bugs or questions
- **Discussions**: Use GitHub discussions for general questions
- **Documentation**: Check existing docs before asking

---

**Note**: This versioning approach is designed specifically for the distributed architecture of Octopets, ensuring all components remain synchronized and deployable together.