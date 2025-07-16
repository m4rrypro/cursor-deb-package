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

# Move extracted files (fix double usr issue)
echo "=== Checking AppImage structure ==="
ls -la squashfs-root/

if [ -d "squashfs-root/usr" ]; then
    echo "Found nested usr directory, merging properly..."
    # Only copy contents of squashfs-root/usr into our usr directory
    cp -r squashfs-root/usr/* usr/
else
    echo "No nested usr directory, moving all files..."
    mv squashfs-root/* usr/
fi

echo "=== Final usr structure ==="
ls -la usr/

# Copy desktop file if not already in place
if [ ! -f usr/share/applications/cursor.desktop ]; then
    # Create desktop file if it doesn't exist
    cat > usr/share/applications/cursor.desktop << EOF
[Desktop Entry]
Name=Cursor
Comment=The AI-first code editor
GenericName=Text Editor
Exec=/usr/bin/cursor %F
Icon=cursor
Type=Application
StartupNotify=true
StartupWMClass=Cursor
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Actions=new-empty-window;
Keywords=cursor;editor;ai;
Terminal=false

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=/usr/bin/cursor --new-window %F
Icon=cursor
EOF
fi

# Use the official Cursor icon from the AppImage if available
ICON_SRC=""
if [ -f usr/share/icons/hicolor/256x256/apps/cursor.png ]; then
    ICON_SRC="usr/share/icons/hicolor/256x256/apps/cursor.png"
elif [ -f usr/cursor.png ]; then
    ICON_SRC="usr/cursor.png"
elif [ -f usr/share/pixmaps/cursor.png ]; then
    ICON_SRC="usr/share/pixmaps/cursor.png"
fi

if [ -n "$ICON_SRC" ]; then
    # Only copy if source and destination are not the same
    if [ "$ICON_SRC" != "usr/share/icons/hicolor/256x256/apps/cursor.png" ]; then
        cp "$ICON_SRC" usr/share/icons/hicolor/256x256/apps/cursor.png
    fi
    cp "$ICON_SRC" usr/share/pixmaps/cursor.png
fi

# Create symlink in /usr/bin
# Find the actual Cursor executable
echo "=== Looking for Cursor executable ==="
CURSOR_EXEC=$(find usr/ -name "cursor" -type f -executable | head -1)

if [ -z "$CURSOR_EXEC" ]; then
    echo "Looking for alternative cursor executables..."
    CURSOR_EXEC=$(find usr/ -path "*/bin/cursor" -type f | head -1)
fi

if [ -z "$CURSOR_EXEC" ]; then
    echo "Looking for any cursor binary..."
    CURSOR_EXEC=$(find usr/ -name "*cursor*" -type f -executable | head -1)
fi

if [ -n "$CURSOR_EXEC" ]; then
    echo "Found Cursor executable: $CURSOR_EXEC"
    # Create relative symlink
    RELATIVE_PATH=$(echo "$CURSOR_EXEC" | sed 's|^usr/||')
    ln -sf "../$RELATIVE_PATH" usr/bin/cursor
    echo "Created symlink: usr/bin/cursor -> ../$RELATIVE_PATH"
else
    echo "WARNING: Could not find Cursor executable!"
    # Create a robust wrapper script instead
    cat > usr/bin/cursor << 'EOF'
#!/bin/bash
# Avoid recursion if this is the wrapper
if [[ "$0" == "/usr/bin/cursor" ]]; then
    REAL_CURSOR=$(find /usr/share/cursor -type f -name "cursor" -executable | head -1)
    if [ -n "$REAL_CURSOR" ]; then
        exec "$REAL_CURSOR" --no-sandbox "$@"
    else
        echo "Error: Cursor executable not found"
        exit 1
    fi
else
    exec cursor "$@"
fi
EOF
    chmod +x usr/bin/cursor
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
