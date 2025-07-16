#!/bin/bash
set -e

# Download Cursor
./scripts/download-cursor.sh

# Convert to DEB
./scripts/convert-to-deb.sh

echo "Build process completed." 