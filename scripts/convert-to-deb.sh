#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Converting Cursor AppImage to .deb package...${NC}"

# Check if AppImage exists
if [ ! -f downloads/filename.txt ]; then
    echo -e "${RED}Error: No AppImage found. Run download-cursor.sh first.${NC}"
    exit 1
fi

FILENAME=$(cat downloads/filename.txt)
VERSION=$(cat downloads/version.txt)
APPIMAGE_PATH="downloads/$FILENAME"

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo -e "${RED}Error: AppImage file not found: $APPIMAGE_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}AppImage: $APPIMAGE_PATH${NC}"
echo -e "${YELLOW}Version: $VERSION${NC}"

# Clean version string (remove 'v' prefix if present)
CLEAN_VERSION=$(echo "$VERSION" | sed 's/^v//')

# Create build directory
BUILD_DIR="build/cursor_${CLEAN_VERSION}"
rm -rf build
mkdir -p "$BUILD_DIR"

echo -e "${YELLOW}Build directory: $BUILD_DIR${NC}"

# Extract AppImage
echo -e "${GREEN}Extracting AppImage...${NC}"
cd "$BUILD_DIR"
"../../$APPIMAGE_PATH" --appimage-extract

# Create debian package structure
echo -e "${GREEN}Creating .deb package structure...${NC}"
mkdir -p DEBIAN
mkdir -p usr/bin
mkdir -p usr/share/applications
mkdir -p usr/share/icons/hicolor/256x256/apps
mkdir -p usr/share/pixmaps

# Move extracted files
mv squashfs-root/* usr/

# Create symlink in /usr/bin
ln -sf ../share/cursor/cursor usr/bin/cursor

# Copy desktop file
if [ -f usr/share/applications/cursor.desktop ]; then
    cp usr/share/applications/cursor.desktop usr/share/applications/
else
    # Create desktop file if it doesn't exist
    cat > usr/share/applications/cursor.desktop << EOF
[Desktop Entry]
Name=Cursor
Comment=The AI-first code editor
GenericName=Text Editor
Exec=cursor %F
Icon=cursor
Type=Application
StartupNotify=true
StartupWMClass=Cursor
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Actions=new-empty-window;
Keywords=cursor;editor;ai;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=cursor --new-window %F
Icon=cursor
EOF
fi

# Copy icon
if [ -f usr/share/pixmaps/cursor.png ]; then
    cp usr/share/pixmaps/cursor.png usr/share/icons/hicolor/256x256/apps/
    cp usr/share/pixmaps/cursor.png usr/share/pixmaps/
elif [ -f usr/cursor.png ]; then
    cp usr/cursor.png usr/share/icons/hicolor/256x256/apps/cursor.png
    cp usr/cursor.png usr/share/pixmaps/cursor.png
fi

# Create control file
cat > DEBIAN/control << EOF
Package: cursor
Version: ${CLEAN_VERSION}
Section: editors
Priority: optional
Architecture: amd64
Depends: libc6, libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libxcomposite1, libxdamage1, libxrandr2, libgbm1, libxkbcommon0, libasound2
Maintainer: Cursor Team <support@cursor.sh>
Homepage: https://cursor.sh
Description: The AI-first code editor
 Cursor is a code editor built for pair-programming with AI.
 It combines the familiar feel of VS Code with powerful AI features
 to help you code faster and more efficiently.
EOF

# Create postinst script
cat > DEBIAN/postinst << 'EOF'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications
fi

# Update icon cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q /usr/share/icons/hicolor
fi

exit 0
EOF

# Create postrm script
cat > DEBIAN/postrm << 'EOF'
#!/bin/bash
set -e

if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
    # Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database -q /usr/share/applications
    fi
    
    # Update icon cache
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q /usr/share/icons/hicolor
    fi
fi

exit 0
EOF

# Make scripts executable
chmod 755 DEBIAN/postinst DEBIAN/postrm

# Remove squashfs-root directory
rm -rf squashfs-root

cd ../..

# Build the .deb package
echo -e "${GREEN}Building .deb package...${NC}"
DEB_FILE="cursor_${CLEAN_VERSION}_amd64.deb"
dpkg-deb --build "$BUILD_DIR" "$DEB_FILE"

echo -e "${GREEN}Package created: $DEB_FILE${NC}"

# Create output directory and move the package
mkdir -p output
mv "$DEB_FILE" output/

echo -e "${GREEN}Conversion completed successfully!${NC}"
echo -e "${GREEN}Package location: output/$DEB_FILE${NC}"
