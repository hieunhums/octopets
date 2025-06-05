#!/bin/bash

# Version validation utility for Octopets
# Ensures all component versions are synchronized

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$ROOT_DIR/version.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed. Please install jq.${NC}"
    exit 1
fi

# Check if version.json exists
if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}Error: version.json not found in $ROOT_DIR${NC}"
    exit 1
fi

echo "🔍 Validating version consistency across Octopets components..."
echo ""

MAIN_VERSION=$(jq -r '.version' "$VERSION_FILE")
VALIDATION_FAILED=false

echo -e "📋 Main version: ${GREEN}$MAIN_VERSION${NC}"
echo ""

# Validate frontend package.json
if [ -f "$ROOT_DIR/frontend/package.json" ]; then
    FRONTEND_VERSION=$(jq -r '.version' "$ROOT_DIR/frontend/package.json")
    echo -n "🌐 Frontend (package.json): "
    if [ "$MAIN_VERSION" = "$FRONTEND_VERSION" ]; then
        echo -e "${GREEN}$FRONTEND_VERSION ✓${NC}"
    else
        echo -e "${RED}$FRONTEND_VERSION ✗${NC}"
        echo -e "   ${YELLOW}Expected: $MAIN_VERSION${NC}"
        VALIDATION_FAILED=true
    fi
else
    echo -e "${YELLOW}⚠️  Frontend package.json not found${NC}"
fi

# Validate backend project files
echo ""
echo "🔧 Backend (.NET projects):"

find "$ROOT_DIR" -name "*.csproj" -type f | while read -r proj_file; do
    if [ -f "$proj_file" ]; then
        relative_path=$(realpath --relative-to="$ROOT_DIR" "$proj_file")
        
        # Check if project has version information
        if grep -q "<Version>" "$proj_file"; then
            PROJECT_VERSION=$(grep "<Version>" "$proj_file" | sed 's/.*<Version>\(.*\)<\/Version>.*/\1/' | head -n1)
            echo -n "   📦 $relative_path: "
            if [ "$MAIN_VERSION" = "$PROJECT_VERSION" ]; then
                echo -e "${GREEN}$PROJECT_VERSION ✓${NC}"
            else
                echo -e "${RED}$PROJECT_VERSION ✗${NC}"
                echo -e "      ${YELLOW}Expected: $MAIN_VERSION${NC}"
                VALIDATION_FAILED=true
            fi
        else
            echo -e "   📦 $relative_path: ${YELLOW}No version specified${NC}"
        fi
    fi
done

# Check component versions in version.json
echo ""
echo "📊 Component versions in version.json:"

COMPONENTS=("frontend" "backend" "apphost" "servicedefaults")
for component in "${COMPONENTS[@]}"; do
    COMPONENT_VERSION=$(jq -r ".components.$component" "$VERSION_FILE")
    echo -n "   🔹 $component: "
    if [ "$MAIN_VERSION" = "$COMPONENT_VERSION" ]; then
        echo -e "${GREEN}$COMPONENT_VERSION ✓${NC}"
    else
        echo -e "${RED}$COMPONENT_VERSION ✗${NC}"
        echo -e "      ${YELLOW}Expected: $MAIN_VERSION${NC}"
        VALIDATION_FAILED=true
    fi
done

# Validate version format
echo ""
echo "🔢 Version format validation:"
if [[ $MAIN_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
    echo -e "   ${GREEN}✓ Version format is valid (SemVer)${NC}"
else
    echo -e "   ${RED}✗ Invalid version format${NC}"
    echo -e "   ${YELLOW}Expected format: MAJOR.MINOR.PATCH[-PRERELEASE][+BUILDMETADATA]${NC}"
    VALIDATION_FAILED=true
fi

# Check git status
echo ""
echo "📝 Git status:"
if git status --porcelain | grep -q "version.json\|package.json\|\.csproj"; then
    echo -e "   ${YELLOW}⚠️  Version-related files have uncommitted changes${NC}"
    git status --porcelain | grep -E "version.json|package.json|\.csproj" | while read -r line; do
        echo "      $line"
    done
else
    echo -e "   ${GREEN}✓ No uncommitted version changes${NC}"
fi

# Check for git tags
echo ""
echo "🏷️  Git tags:"
if git tag --list | grep -q "v$MAIN_VERSION"; then
    echo -e "   ${YELLOW}⚠️  Tag v$MAIN_VERSION already exists${NC}"
else
    echo -e "   ${GREEN}✓ Tag v$MAIN_VERSION does not exist yet${NC}"
fi

# Summary
echo ""
echo "📋 Validation Summary:"
if [ "$VALIDATION_FAILED" = true ]; then
    echo -e "${RED}❌ Version validation FAILED${NC}"
    echo ""
    echo "🔧 To fix version inconsistencies, run:"
    echo "   ./scripts/sync-versions.sh"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ All versions are consistent!${NC}"
    echo ""
    echo "🚀 Ready for release:"
    echo "   Current version: $MAIN_VERSION"
    echo "   All components synchronized"
    echo ""
fi