#!/bin/bash

# PP MAMS Version Update Script
# Updates version from 1.04 to 1.05 across all project files

set -e

NEW_VERSION="1.05"
NEW_VERSION_NUM="105"
OLD_VERSION="1.04"
OLD_VERSION_NUM="104"
TODAY=$(date '+%Y-%m-%d')

echo "🚀 PP MAMS Version Update Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Updating from v${OLD_VERSION} to v${NEW_VERSION}"
echo "📅 Date: ${TODAY}"
echo ""

# Function to update files
update_file() {
    local file="$1"
    local description="$2"

    if [[ -f "$file" ]]; then
        echo "📝 Updating $description: $file"
        # Create backup
        cp "$file" "${file}.backup"
        return 0
    else
        echo "❌ File not found: $file"
        return 1
    fi
}

# Function to verify update
verify_update() {
    local file="$1"
    local pattern="$2"

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo "✅ Verified: $file contains $pattern"
    else
        echo "❌ Failed: $file does not contain $pattern"
    fi
}

echo "🔧 Step 1: Updating content.xml"
if update_file "pp_mams/content.xml" "Content XML"; then
    # Update version number (104 -> 105)
    sed -i "s/version=\"${OLD_VERSION_NUM}\"/version=\"${NEW_VERSION_NUM}\"/g" pp_mams/content.xml

    # Update version in description (v1.04 -> v1.05)
    sed -i "s/v${OLD_VERSION}/v${NEW_VERSION}/g" pp_mams/content.xml

    # Update date
    sed -i "s/date=\"[0-9-]*\"/date=\"${TODAY}\"/g" pp_mams/content.xml
fi

echo ""
echo "🔧 Step 2: Updating MDScript"
if update_file "pp_mams/md/pp_mams.xml" "MDScript XML"; then
    # Update version in debug text
    sed -i "s/version ${OLD_VERSION}/version ${NEW_VERSION}/g" pp_mams/md/pp_mams.xml
fi

echo ""
echo "🔧 Step 3: Updating README.md"
if update_file "README.md" "README documentation"; then
    # Add new version entry at the top of changelog
    sed -i "/^## Changelog/a\\
\\
- **v${NEW_VERSION}** (${TODAY}): Fixed MDScript syntax errors - pilot firing now works correctly" README.md
fi

echo ""
echo "🔍 Step 4: Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

verify_update "pp_mams/content.xml" "version=\"${NEW_VERSION_NUM}\""
verify_update "pp_mams/content.xml" "v${NEW_VERSION}"
verify_update "pp_mams/md/pp_mams.xml" "version ${NEW_VERSION}"
verify_update "README.md" "v${NEW_VERSION}"

echo ""
echo "🔍 Step 5: Checking for remaining old version references"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Searching for old version references (excluding historic records):"
FOUND_OLD=$(grep -r "${OLD_VERSION}" . \
    --exclude-dir=.git \
    --exclude-dir=backup_v1.00 \
    --exclude="*.backup" \
    --exclude="update_version.sh" \
    2>/dev/null || true)

if [[ -n "$FOUND_OLD" ]]; then
    echo "⚠️  Found remaining old version references:"
    echo "$FOUND_OLD"
else
    echo "✅ No old version references found (excluding historic records)"
fi

echo ""
echo "📊 Final Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Version updated from v${OLD_VERSION} to v${NEW_VERSION}"
echo "✅ Date updated to ${TODAY}"
echo "✅ Backup files created (.backup extension)"
echo ""
echo "📁 Updated files:"
echo "  - pp_mams/content.xml"
echo "  - pp_mams/md/pp_mams.xml"
echo "  - README.md"
echo ""
echo "🎯 Ready for testing and commit!"
echo ""