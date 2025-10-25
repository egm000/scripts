#!/usr/bin/env bash
#
# Timeshift Backup Transfer Script
# Works for Pop!_OS + Windows dual-boot systems
# Creates a Timeshift snapshot and transfers it to an NTFS drive for temporary storage
#
# Usage:
#   sudo ./timeshift_backup_transfer.sh backup
#   sudo ./timeshift_backup_transfer.sh restore
#

# === CONFIGURATION ===
WIN_MOUNT="/media/egm0/Stores/timeshift/"   # path to your mounted Windows (NTFS) drive
WIN_BACKUP_FOLDER="$WIN_MOUNT/timeshift_backup"
LINUX_TIMESHIFT_FOLDER="/timeshift/snapshots"

# === FUNCTIONS ===

create_backup() {
    echo "🕐 Creating Timeshift snapshot..."
    sudo timeshift --create --comments "Auto-backup before system changes" || {
        echo "❌ Timeshift snapshot failed."
        exit 1
    }

    echo "✅ Snapshot created. Copying to Windows SSD..."
    sudo rsync -aAXv --progress "$LINUX_TIMESHIFT_FOLDER/" "$WIN_BACKUP_FOLDER/" || {
        echo "❌ Copy failed."
        exit 1
    }

    echo "✅ Backup successfully copied to $WIN_BACKUP_FOLDER"
}

restore_backup() {
    echo "🔁 Restoring Timeshift snapshots from Windows SSD..."
    sudo rsync -aAXv --progress "$WIN_BACKUP_FOLDER/" "$LINUX_TIMESHIFT_FOLDER/" || {
        echo "❌ Copy failed."
        exit 1
    }

    echo "✅ Snapshots restored to $LINUX_TIMESHIFT_FOLDER"
    echo "➡️  Now open Timeshift (sudo timeshift-gtk) and choose your snapshot to restore."
}

# === MAIN ===
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
