#!/bin/bash
# QML Validation Script
# Validates QML files for syntax errors and common issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== QML Validation ==="
echo ""

# Find qmllint - try common locations
QMLLINT=""
if command -v qmllint &> /dev/null; then
    QMLLINT="qmllint"
elif command -v qmllint-qt6 &> /dev/null; then
    QMLLINT="qmllint-qt6"
elif [ -f "/opt/homebrew/opt/qt/bin/qmllint" ]; then
    QMLLINT="/opt/homebrew/opt/qt/bin/qmllint"
elif [ -f "/usr/local/opt/qt/bin/qmllint" ]; then
    QMLLINT="/usr/local/opt/qt/bin/qmllint"
fi

# Track results
ERRORS=0
WARNINGS=0
CHECKED=0

# Validate QML syntax using Python regex
validate_qml_syntax() {
    local file="$1"
    local issues=0

    # Check for uppercase IDs (QML error)
    if grep -n "id:\s*[A-Z]" "$file" 2>/dev/null | grep -v "//"; then
        echo -e "${RED}ERROR${NC}: $file - ID starting with uppercase letter"
        ((issues++))
    fi

    # Check for undefined assigned to typed properties
    if grep -n ": undefined" "$file" 2>/dev/null | grep -v "//"; then
        echo -e "${RED}ERROR${NC}: $file - Assignment of 'undefined' to property"
        ((issues++))
    fi

    # Check for missing imports when using Core components
    if grep -q "Core\." "$file" && ! grep -q "import Core" "$file"; then
        echo -e "${RED}ERROR${NC}: $file - Uses Core.* but missing 'import Core'"
        ((issues++))
    fi

    # Check for Core import without 'as Core'
    if grep -q "^import Core$" "$file"; then
        echo -e "${YELLOW}WARNING${NC}: $file - Use 'import Core as Core' for namespace"
        ((WARNINGS++))
    fi

    return $issues
}

# Validate all QML files in apps directory
echo "Checking QML files in device/apps/..."
echo ""

# Find all QML files (excluding ui/qml which is legacy)
find "$PROJECT_ROOT/device/apps" -name "*.qml" -not -path "*/ui/qml/*" | while read -r qml_file; do
    ((CHECKED++)) || true

    # Run qmllint if available
    if [ -n "$QMLLINT" ]; then
        if ! $QMLLINT "$qml_file" 2>&1 | grep -q "Error\|error"; then
            : # No errors
        else
            echo -e "${RED}ERROR${NC}: $qml_file"
            $QMLLINT "$qml_file" 2>&1 | head -5
            ((ERRORS++)) || true
        fi
    fi

    # Run custom syntax validation
    validate_qml_syntax "$qml_file" || ((ERRORS++)) || true
done

# Also validate Core components
echo ""
echo "Checking Core components..."
find "$PROJECT_ROOT/device/apps/core/Core" -name "*.qml" | while read -r qml_file; do
    ((CHECKED++)) || true
    validate_qml_syntax "$qml_file" || ((ERRORS++)) || true
done

echo ""
echo "=== Summary ==="
echo "Files checked: $CHECKED"
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}Errors: $ERRORS${NC}"
    exit 1
else
    echo -e "${GREEN}No errors found!${NC}"
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi
