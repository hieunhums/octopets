#!/bin/bash

# Version bump utility for Octopets
# Usage: ./scripts/bump-version.sh [major|minor|patch|rc|beta|alpha]

set -e

VERSION_TYPE=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$ROOT_DIR/version.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq."
    exit 1
fi

# Check if version.json exists
if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: version.json not found in $ROOT_DIR"
    exit 1
fi

CURRENT_VERSION=$(jq -r '.version' "$VERSION_FILE")

if [ -z "$VERSION_TYPE" ]; then
    echo "Current version: $CURRENT_VERSION"
    echo "Usage: $0 [major|minor|patch|rc|beta|alpha]"
    echo ""
    echo "Examples:"
    echo "  $0 patch    # 1.0.0 -> 1.0.1"
    echo "  $0 minor    # 1.0.0 -> 1.1.0"
    echo "  $0 major    # 1.0.0 -> 2.0.0"
    echo "  $0 rc       # 1.0.0 -> 1.0.0-rc.1"
    exit 0
fi

# Extract version components
if [[ $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-(.+))?$ ]]; then
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    PATCH=${BASH_REMATCH[3]}
    PRERELEASE=${BASH_REMATCH[5]}
else
    echo "Error: Invalid version format: $CURRENT_VERSION"
    exit 1
fi

# Calculate new version
case $VERSION_TYPE in
  major)
    NEW_VERSION="$((MAJOR + 1)).0.0"
    ;;
  minor)
    NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
    ;;
  patch)
    NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
    ;;
  rc)
    BASE_VERSION="$MAJOR.$MINOR.$PATCH"
    if [[ $PRERELEASE == rc.* ]]; then
      RC_NUM=$(echo "$PRERELEASE" | sed 's/rc\.//')
      NEW_VERSION="$BASE_VERSION-rc.$((RC_NUM + 1))"
    else
      NEW_VERSION="$BASE_VERSION-rc.1"
    fi
    ;;
  beta)
    BASE_VERSION="$MAJOR.$MINOR.$PATCH"
    if [[ $PRERELEASE == beta.* ]]; then
      BETA_NUM=$(echo "$PRERELEASE" | sed 's/beta\.//')
      NEW_VERSION="$BASE_VERSION-beta.$((BETA_NUM + 1))"
    else
      NEW_VERSION="$BASE_VERSION-beta.1"
    fi
    ;;
  alpha)
    BASE_VERSION="$MAJOR.$MINOR.$PATCH"
    if [[ $PRERELEASE == alpha.* ]]; then
      ALPHA_NUM=$(echo "$PRERELEASE" | sed 's/alpha\.//')
      NEW_VERSION="$BASE_VERSION-alpha.$((ALPHA_NUM + 1))"
    else
      NEW_VERSION="$BASE_VERSION-alpha.1"
    fi
    ;;
  *)
    echo "Error: Invalid version type: $VERSION_TYPE"
    echo "Valid types: major, minor, patch, rc, beta, alpha"
    exit 1
    ;;
esac

echo "Bumping version from $CURRENT_VERSION to $NEW_VERSION"

# Update version.json
TEMP_FILE=$(mktemp)
jq --arg version "$NEW_VERSION" --arg date "$(date -u +%Y-%m-%d)" '
  .version = $version |
  .releaseDate = $date |
  .components.frontend = $version |
  .components.backend = $version |
  .components.apphost = $version |
  .components.servicedefaults = $version
' "$VERSION_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$VERSION_FILE"

# Update frontend package.json if it exists
if [ -f "$ROOT_DIR/frontend/package.json" ]; then
    echo "Updating frontend/package.json..."
    cd "$ROOT_DIR/frontend"
    npm version "$NEW_VERSION" --no-git-tag-version --allow-same-version
    cd "$ROOT_DIR"
fi

# Update backend project files
echo "Updating .NET project files..."
find "$ROOT_DIR" -name "*.csproj" -type f | while read -r proj_file; do
    if [ -f "$proj_file" ]; then
        # Create a backup
        cp "$proj_file" "$proj_file.bak"
        
        # Update version tags
        sed -i.tmp \
            -e "s|<Version>.*</Version>|<Version>$NEW_VERSION</Version>|g" \
            -e "s|<AssemblyVersion>.*</AssemblyVersion>|<AssemblyVersion>$NEW_VERSION.0</AssemblyVersion>|g" \
            -e "s|<FileVersion>.*</FileVersion>|<FileVersion>$NEW_VERSION.0</FileVersion>|g" \
            -e "s|<InformationalVersion>.*</InformationalVersion>|<InformationalVersion>$NEW_VERSION</InformationalVersion>|g" \
            "$proj_file"
        
        # Remove backup files
        rm -f "$proj_file.tmp" "$proj_file.bak"
        
        echo "  Updated: $proj_file"
    fi
done

echo ""
echo "✅ Version successfully updated to $NEW_VERSION"
echo ""
echo "Updated files:"
echo "  - version.json"
echo "  - frontend/package.json"
echo "  - All .csproj files"
echo ""
echo "Next steps:"
echo "  1. Review the changes"
echo "  2. Commit the version bump"
echo "  3. Create a git tag: git tag v$NEW_VERSION"
echo "  4. Push changes: git push origin main --tags"