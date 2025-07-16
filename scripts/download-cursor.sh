#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Downloading latest Cursor AppImage...${NC}"

# Create downloads directory
mkdir -p downloads

# Use the official Cursor API to get the latest download URL
echo -e "${YELLOW}Fetching latest Cursor AppImage URL from API...${NC}"

# Official Cursor API endpoint for Linux x64
API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

# Get the actual download URL from the API
DOWNLOAD_URL=$(curl -sL -A "$USER_AGENT" "$API_URL" | jq -r '.url // .downloadUrl')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo -e "${RED}Error: Could not get download URL from Cursor API${NC}"
    exit 1
fi

echo -e "${YELLOW}Download URL: $DOWNLOAD_URL${NC}"

# Extract filename from URL or generate one
FILENAME=$(basename "$DOWNLOAD_URL" | sed 's/?.*$//')
if [[ ! "$FILENAME" =~ \.AppImage$ ]]; then
    # If we can't extract a proper filename, generate one
    TIMESTAMP=$(date +"%Y%m%d")
    FILENAME="cursor-${TIMESTAMP}-x86_64.AppImage"
fi
echo -e "${YELLOW}Filename: $FILENAME${NC}"

# Download the AppImage
echo -e "${GREEN}Downloading $FILENAME...${NC}"
wget -O "downloads/$FILENAME" "$DOWNLOAD_URL"

# Make it executable
chmod +x "downloads/$FILENAME"

echo -e "${GREEN}Download completed: downloads/$FILENAME${NC}"

# Try to extract version information
echo -e "${YELLOW}Extracting version information...${NC}"

# First try to get version from API response
VERSION=$(curl -sL -A "$USER_AGENT" "$API_URL" | jq -r '.version // empty')

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    # Try to extract from filename
    VERSION=$(echo "$FILENAME" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi

if [ -z "$VERSION" ]; then
    # Try to extract version from the AppImage itself
    cd downloads
    ./$FILENAME --appimage-extract >/dev/null 2>&1 || true
    
    # Look for version in various places
    if [ -f "squashfs-root/resources/app/package.json" ]; then
        VERSION=$(grep '"version"' squashfs-root/resources/app/package.json | cut -d'"' -f4 2>/dev/null || echo "")
    elif [ -f "squashfs-root/package.json" ]; then
        VERSION=$(grep '"version"' squashfs-root/package.json | cut -d'"' -f4 2>/dev/null || echo "")
    fi
    
    # Clean up extraction
    rm -rf squashfs-root
    cd ..
fi

# If we still couldn't get version, use timestamp
if [ -z "$VERSION" ]; then
    TIMESTAMP=$(date +"%Y%m%d")
    VERSION="1.0.${TIMESTAMP}"
fi

echo -e "${GREEN}Version: $VERSION${NC}"

# Save version info
echo "$VERSION" > downloads/version.txt
echo "$FILENAME" > downloads/filename.txt

echo -e "${GREEN}Download process completed successfully!${NC}"
