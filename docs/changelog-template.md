# Changelog Template

All notable changes to the Octopets project will be documented using this template.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security vulnerability fixes

## [1.0.0] - YYYY-MM-DD

### Added
- Initial stable release
- All core functionality implemented
- Production-ready deployment

### Changed
- N/A (initial release)

### Fixed
- All critical bugs resolved for production

## [0.2.0] - YYYY-MM-DD

### Added
- New feature examples
- Additional API endpoints
- Enhanced user interface

### Changed
- Improved performance
- Better error handling

### Fixed
- Various bug fixes

## [0.1.0] - YYYY-MM-DD

### Added
- Initial project structure
- Basic frontend application
- Backend API foundation
- Aspire AppHost orchestration
- Development environment setup

---

## Template Instructions

### Version Format
Use semantic versioning format: `[MAJOR.MINOR.PATCH]`

### Date Format
Use ISO date format: `YYYY-MM-DD`

### Categories
Always use these standard categories in order:
1. **Added** - for new features
2. **Changed** - for changes in existing functionality  
3. **Deprecated** - for soon-to-be removed features
4. **Removed** - for now removed features
5. **Fixed** - for any bug fixes
6. **Security** - in case of vulnerabilities

### Writing Guidelines
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line
- Consider including screenshots for UI changes

### Examples
```markdown
### Added
- New listing search functionality for better user experience
- API endpoint for advanced filtering (#123)
- Dark mode support in frontend (#145)

### Changed
- Improved database query performance by 50%
- Updated React Router to v6 (#134)
- Enhanced error messages for better debugging

### Fixed
- Fixed memory leak in listing component (#156)
- Resolved CORS issues in production deployment (#167)
- Fixed responsive layout on mobile devices (#178)

### Security
- Updated dependencies to fix security vulnerabilities
- Implemented rate limiting for API endpoints
- Added input validation to prevent XSS attacks
```

### Release Process Integration
1. Update changelog with new version section
2. Move items from "Unreleased" to the new version
3. Add release date
4. Create git tag with version number
5. Update version.json and component versions
6. Deploy to production

### Automation
The changelog should be updated as part of the release process:
```bash
# Before release
./scripts/bump-version.sh minor
# Update changelog manually
git add CHANGELOG.md
git commit -m "Update changelog for v1.1.0"
```