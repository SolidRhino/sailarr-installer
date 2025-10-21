#!/bin/bash

# MediaCenter Permission Fix Script
# This script fixes permissions for all media directories to ensure
# all members of the mediacenter group can read/write properly

echo "======================================"
echo "  MediaCenter Permission Fix Script"
echo "======================================"
echo ""
echo "This script will fix permissions for:"
echo "  - /mediacenter/data/"
echo "  - /mediacenter/config/"
echo ""
echo "All directories: 775 (rwxrwxr-x)"
echo "All files: 664 (rw-rw-r--)"
echo "Group: mediacenter (GID 13000)"
echo ""
echo "REQUIRES SUDO PRIVILEGES"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Starting permission fix..."
echo ""

# Fix data directories
echo "==> Fixing /mediacenter/data/ permissions..."

# Fix directory permissions (775)
echo "    Setting directory permissions to 775..."
sudo find /mediacenter/data/ -type d -exec chmod 775 {} \; 2>/dev/null

# Fix file permissions (664) - but preserve executable files
echo "    Setting file permissions to 664 (preserving executables)..."
sudo find /mediacenter/data/ -type f ! -perm -111 -exec chmod 664 {} \; 2>/dev/null
sudo find /mediacenter/data/ -type f -perm -111 -exec chmod 775 {} \; 2>/dev/null

# Fix group ownership
echo "    Setting group ownership to mediacenter..."
sudo chgrp -R mediacenter /mediacenter/data/ 2>/dev/null

echo ""
echo "==> Fixing /mediacenter/config/ permissions..."

# Fix directory permissions (775)
echo "    Setting directory permissions to 775..."
sudo find /mediacenter/config/ -type d -exec chmod 775 {} \; 2>/dev/null

# Fix file permissions (664) - but preserve executable files
echo "    Setting file permissions to 664 (preserving executables)..."
sudo find /mediacenter/config/ -type f ! -perm -111 -exec chmod 664 {} \; 2>/dev/null
sudo find /mediacenter/config/ -type f -perm -111 -exec chmod 775 {} \; 2>/dev/null

# Fix group ownership
echo "    Setting group ownership to mediacenter..."
sudo chgrp -R mediacenter /mediacenter/config/ 2>/dev/null

echo ""
echo "==> Special handling for symlinks..."
# Symlinks themselves should be 777 (lrwxrwxrwx) which is default
# We just ensure the directories containing them have proper permissions
sudo find /mediacenter/data/symlinks/ -type d -exec chmod 775 {} \; 2>/dev/null
sudo find /mediacenter/data/media/ -type d -exec chmod 775 {} \; 2>/dev/null

echo ""
echo "======================================"
echo "  Permission Fix Complete!"
echo "======================================"
echo ""
echo "Summary:"
echo "  - All directories: 775 (rwxrwxr-x)"
echo "  - All files: 664 (rw-rw-r--)"
echo "  - Executables: 775 (rwxrwxr-x)"
echo "  - Group: mediacenter"
echo ""
echo "Next steps:"
echo "  1. Restart all containers with: ./down.sh && ./up.sh"
echo "  2. Test that Radarr/Sonarr can now import properly"
echo ""