#!/usr/bin/env bash
#
# Timeshift Backup Transfer Script (Pop!_OS + Windows Dual Boot)
# -------------------------------------------------------------
# Creates a Timeshift snapshot and safely copies it to an NTFS Windows SSD.
# Can also restore the snapshot folder back to the Linux disk after reinstall.
#
# Usage:
#   sudo ./timeshift_backup_transfer.sh backup
#   sudo ./timeshift_backup_transfer.sh restore
#

set -e

# === SETTINGS ===
LINUX_TIMESHIFT_FOLDER="/timeshift/snapshots"
WIN_BACKUP_SUBFOLDER="timeshift_backup"

# === FUNCTIONS ===

find_windows_mount() {
    echo "🔍 Searching for mounted Windows NTFS partition..."
    # Try to detect a mounted NTFS partition under /media/$USER/
    WIN_MOUNT=$(find /media/"${SUDO_USER: -$USER}" -maxdepth 2 -type d -iname "Windows*" -print -quit 2>/dev/null)

    if [[ -z "$WIN_MOUNT" ]]; then
        echo "⚠️  No Windows partition found under /media/$USER/"
        echo "➡️  Please mount your Windows SSD (open it in Files) and rerun this script."
        exit 1
    fi

    echo "✅ Found Windows drive at: $WIN_MOUNT"
    WIN_BACKUP_FOLDER="$WIN_MOUNT/$WIN_BACKUP_SUBFOLDER"
    mkdir -p "$WIN_BACKUP_FOLDER"
}

create_backup() {
    echo "🕐 Creating Timeshift snapshot..."
    sudo timeshift --create --comments "Auto-backup before system changes" || {
        echo "❌ Timeshift snapshot failed."
        exit 1
    }

    echo "✅ Snapshot created. Copying to Windows SSD..."
    sudo rsync -av --no-perms --no-owner --no-group --progress \
        "$LINUX_TIMESHIFT_FOLDER/" "$WIN_BACKUP_FOLDER/" || {
        echo "❌ Copy failed."
        exit 1
    }

    echo "✅ Backup successfully copied to $WIN_BACKUP_FOLDER"
}

restore_backup() {
    echo "🔁 Copying Timeshift snapshots from Windows SSD back to Linux disk..."
    sudo rsync -av --no-perms --no-owner --no-group --progress \
        "$WIN_BACKUP_FOLDER/" "$LINUX_TIMESHIFT_FOLDER/" || {
        echo "❌ Copy failed."
        exit 1
    }

    echo "✅ Snapshots restored to $LINUX_TIMESHIFT_FOLDER"
    echo "➡️  Now run:  sudo timeshift-gtk"
    echo "   and choose your snapshot to restore."
}

# === MAIN ===

if [[ $EUID -ne 0 ]]; then
    echo "⚠️  Please run this script with sudo:"
    echo "   sudo $0 {backup|restore}"
    exit 1
fi

if [[ -z "$1" ]]; then
    echo "Usage: sudo $0 {backup|restore}"
    exit 1
fi

find_windows_mount

case "$1" in
    backup)
        create_backup
        ;;
    restore)
        restore_backup
        ;;
    *)
        echo "Usage: sudo $0 {backup|restore}"
        ;;
esac
