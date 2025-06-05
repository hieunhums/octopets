#!/bin/bash

# Version synchronization utility for Octopets
# Synchronizes all component versions with the main version from version.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$ROOT_DIR/version.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

MAIN_VERSION=$(jq -r '.version' "$VERSION_FILE")

echo -e "${BLUE}🔄 Synchronizing all components to version $MAIN_VERSION${NC}"
echo ""

# Update component versions in version.json
echo "📝 Updating component versions in version.json..."
TEMP_FILE=$(mktemp)
jq --arg version "$MAIN_VERSION" '
  .components.frontend = $version |
  .components.backend = $version |
  .components.apphost = $version |
  .components.servicedefaults = $version
' "$VERSION_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$VERSION_FILE"
echo -e "   ${GREEN}✓ version.json updated${NC}"

# Update frontend package.json
if [ -f "$ROOT_DIR/frontend/package.json" ]; then
    echo ""
    echo "🌐 Updating frontend package.json..."
    cd "$ROOT_DIR/frontend"
    
    # Check current version
    CURRENT_FRONTEND_VERSION=$(jq -r '.version' package.json)
    if [ "$CURRENT_FRONTEND_VERSION" != "$MAIN_VERSION" ]; then
        npm version "$MAIN_VERSION" --no-git-tag-version --allow-same-version
        echo -e "   ${GREEN}✓ Frontend version updated: $CURRENT_FRONTEND_VERSION → $MAIN_VERSION${NC}"
    else
        echo -e "   ${YELLOW}⚠️ Frontend version already correct: $MAIN_VERSION${NC}"
    fi
    
    cd "$ROOT_DIR"
else
    echo -e "${YELLOW}⚠️ Frontend package.json not found${NC}"
fi

# Update backend project files
echo ""
echo "🔧 Updating .NET project files..."

PROJECT_COUNT=0
UPDATED_COUNT=0

find "$ROOT_DIR" -name "*.csproj" -type f | while read -r proj_file; do
    if [ -f "$proj_file" ]; then
        relative_path=$(realpath --relative-to="$ROOT_DIR" "$proj_file")
        PROJECT_COUNT=$((PROJECT_COUNT + 1))
        
        # Check if project already has correct version
        if grep -q "<Version>$MAIN_VERSION</Version>" "$proj_file"; then
            echo -e "   ${YELLOW}⚠️ $relative_path already has correct version${NC}"
        else
            # Create a backup
            cp "$proj_file" "$proj_file.bak"
            
            # Check if project has version tags, if not add them
            if ! grep -q "<Version>" "$proj_file"; then
                # Add version information to PropertyGroup
                sed -i.tmp '/<PropertyGroup>/a\
    <Version>'$MAIN_VERSION'</Version>\
    <AssemblyVersion>'$MAIN_VERSION'.0</AssemblyVersion>\
    <FileVersion>'$MAIN_VERSION'.0</FileVersion>\
    <InformationalVersion>'$MAIN_VERSION'</InformationalVersion>
' "$proj_file"
                echo -e "   ${GREEN}✓ $relative_path version information added${NC}"
            else
                # Update existing version tags
                sed -i.tmp \
                    -e "s|<Version>.*</Version>|<Version>$MAIN_VERSION</Version>|g" \
                    -e "s|<AssemblyVersion>.*</AssemblyVersion>|<AssemblyVersion>$MAIN_VERSION.0</AssemblyVersion>|g" \
                    -e "s|<FileVersion>.*</FileVersion>|<FileVersion>$MAIN_VERSION.0</FileVersion>|g" \
                    -e "s|<InformationalVersion>.*</InformationalVersion>|<InformationalVersion>$MAIN_VERSION</InformationalVersion>|g" \
                    "$proj_file"
                echo -e "   ${GREEN}✓ $relative_path version updated${NC}"
            fi
            
            # Remove backup files
            rm -f "$proj_file.tmp" "$proj_file.bak"
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        fi
    fi
done

# Update build metadata
echo ""
echo "📊 Updating build metadata..."
TEMP_FILE=$(mktemp)
jq --arg buildDate "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
  .buildMetadata.buildDate = $buildDate
' "$VERSION_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$VERSION_FILE"
echo -e "   ${GREEN}✓ Build metadata updated${NC}"

# Summary
echo ""
echo -e "${BLUE}📋 Synchronization Summary:${NC}"
echo -e "   Main version: ${GREEN}$MAIN_VERSION${NC}"
echo -e "   Components synchronized: ${GREEN}All${NC}"
echo -e "   Files updated: ${GREEN}version.json, package.json, *.csproj${NC}"
echo ""

# Validate the synchronization
echo -e "${BLUE}🔍 Running validation...${NC}"
if [ -f "$SCRIPT_DIR/validate-versions.sh" ]; then
    "$SCRIPT_DIR/validate-versions.sh"
else
    echo -e "${YELLOW}⚠️ Validation script not found, skipping validation${NC}"
fi

echo ""
echo -e "${GREEN}✅ Version synchronization completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Commit the synchronized versions: git add . && git commit -m 'Sync versions to $MAIN_VERSION'"
echo "  3. Create a tag if this is a release: git tag v$MAIN_VERSION"