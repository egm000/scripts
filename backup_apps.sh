#!/bin/bash

# Output file
OUTPUT_FILE="installed_apps_backup.txt"
echo "User Installed Applications Backup" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# APT packages
echo "APT Packages:" >> "$OUTPUT_FILE"
apt list --installed 2>/dev/null | tail -n +2 | awk -F/ '{print "  - " $1}' >> "$OUTPUT_FILE"

# Snap packages
if command -v snap &> /dev/null; then
    echo "" >> "$OUTPUT_FILE"
    echo "Snap Packages:" >> "$OUTPUT_FILE"
    snap list | tail -n +2 | awk '{print "  - " $1 " " $2}' >> "$OUTPUT_FILE"
else
    echo "" >> "$OUTPUT_FILE"
    echo "Snap Packages: (snap not installed)" >> "$OUTPUT_FILE"
fi

# Flatpak packages
if command -v flatpak &> /dev/null; then
    echo "" >> "$OUTPUT_FILE"
    echo "Flatpak Packages:" >> "$OUTPUT_FILE"
    flatpak list --app --columns=name,version | tail -n +2 | awk '{print "  - " $1 " " $2}' >> "$OUTPUT_FILE"
else
    echo "" >> "$OUTPUT_FILE"
    echo "Flatpak Packages: (flatpak not installed)" >> "$OUTPUT_FILE"
fi

echo "Backup saved to $OUTPUT_FILE"
