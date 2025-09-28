#!/bin/bash

# PP MAMS Mod Installation Script
# Copies mod files from development directory to X4 extensions

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SOURCE_DIR="/home/meldrey/Projects/PRJ-369-017-x4_pp_mams/pp_mams"
TARGET_DIR="/home/steam/.local/share/Steam/steamapps/common/X4 Foundations/extensions/pp_mams"

echo -e "${BLUE}🚀 PP MAMS Mod Installation Script${NC}"
echo "========================================"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ ERROR: Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

# Check if X4 is installed
X4_DIR="/home/steam/.local/share/Steam/steamapps/common/X4 Foundations"
if [ ! -d "$X4_DIR" ]; then
    echo -e "${RED}❌ ERROR: X4 Foundations not found at: $X4_DIR${NC}"
    exit 1
fi

# Get current version from source
if [ -f "$SOURCE_DIR/md/pp_mams.xml" ]; then
    CURRENT_VERSION=$(grep "version 1\." "$SOURCE_DIR/md/pp_mams.xml" | head -1 | sed -E "s/.*version ([0-9]+\.[0-9]+).*/\1/")
    echo -e "${BLUE}📦 Installing PP MAMS version: $CURRENT_VERSION${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Could not detect version${NC}"
fi

# Create backup if target exists
if [ -d "$TARGET_DIR" ]; then
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}📋 Creating backup: $BACKUP_DIR${NC}"
    sudo cp -r "$TARGET_DIR" "$BACKUP_DIR"
fi

# Create target directory if it doesn't exist
echo -e "${BLUE}📁 Preparing target directory...${NC}"
sudo mkdir -p "$TARGET_DIR"

# Copy files
echo -e "${BLUE}📄 Copying mod files...${NC}"
echo "  • content.xml"
sudo cp "$SOURCE_DIR/content.xml" "$TARGET_DIR/"

echo "  • md/pp_mams.xml"
sudo mkdir -p "$TARGET_DIR/md"
sudo cp "$SOURCE_DIR/md/pp_mams.xml" "$TARGET_DIR/md/"

# Set proper permissions
echo -e "${BLUE}🔧 Setting permissions...${NC}"
sudo chown -R steam:steam "$TARGET_DIR"
sudo chmod -R 755 "$TARGET_DIR"

# Verify installation
echo ""
echo -e "${BLUE}✅ Verification:${NC}"
if [ -f "$TARGET_DIR/content.xml" ] && [ -f "$TARGET_DIR/md/pp_mams.xml" ]; then
    echo -e "${GREEN}✓ All files copied successfully${NC}"

    # Check version in installed file
    if [ -f "$TARGET_DIR/md/pp_mams.xml" ]; then
        INSTALLED_VERSION=$(grep "version 1\." "$TARGET_DIR/md/pp_mams.xml" | head -1 | sed -E "s/.*version ([0-9]+\.[0-9]+).*/\1/")
        echo -e "${GREEN}✓ Installed version: $INSTALLED_VERSION${NC}"
    fi

    echo -e "${GREEN}✓ Permissions set correctly${NC}"
    echo ""
    echo -e "${GREEN}🎉 PP MAMS mod installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo "  1. Save your current X4 game"
    echo "  2. Exit to main menu or restart X4"
    echo "  3. Load your save to activate the new version"
    echo ""
else
    echo -e "${RED}❌ Installation failed - files missing${NC}"
    exit 1
fi

echo -e "${BLUE}📍 Installation complete!${NC}"
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"