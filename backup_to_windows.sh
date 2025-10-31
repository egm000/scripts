#!/bin/bash
set -e

# === CONFIGURATION ===
SRC_DOCS="$HOME/Documents/"
SRC_DL="$HOME/Downloads/"
DEST_DOCS="/media/egm0/Stores/Saker/Linux_backup/Documents/"
DEST_DL="/media/egm0/Stores/Saker/Linux_backup/Downloads/"

# === FUNCTIONS ===
check_mount() {
    if ! mount | grep -q "/media/egm0/Stores"; then
        echo "⚠️  Drive not mounted — trying to mount..."
        if [[ -b /dev/nvme1n1p3 ]]; then
            sudo mount -t ntfs3 -o rw,uid=$(id -u),gid=$(id -g) /dev/nvme1n1p3 "/media/egm0/Stores" || {
                echo "❌ Could not mount /media/egm0/Stores"; exit 1;
            }
        else
            echo "❌ Drive device not found (adjust /dev/nvme1n1p3 if different)"; exit 1;
        fi
    fi
}

scan_invalid_names() {
    echo "🔍 Scanning for NTFS-incompatible filenames..."
    INVALID_FILES=$(find "$1" -type f -regextype posix-extended -regex '.*[<>:"/\\|?*].*' -o -name "* " 2>/dev/null || true)
    if [[ -n "$INVALID_FILES" ]]; then
        echo "⚠️  The following files have names invalid on Windows and will be skipped:"
        echo "$INVALID_FILES"
        echo "💡 Tip: Rename them to remove forbidden characters or trailing spaces."
        echo
    else
        echo "✅ No invalid filenames found in $1"
    fi
}

backup_folder() {
    local SRC="$1"
    local DEST="$2"
    local LABEL="$3"
    echo "🔄 Backing up $LABEL..."
    rsync -avh \
        --no-perms --no-owner --no-group --no-times --progress \
        --exclude '*[<>:"/\\|?*]*' --exclude '* ' \
        "$SRC" "$DEST"
    echo "✅ $LABEL backup complete!"
}

# === MAIN ===
echo "🚀 Starting backup..."

check_mount

mkdir -p "$DEST_DOCS" "$DEST_DL"

scan_invalid_names "$SRC_DOCS"
scan_invalid_names "$SRC_DL"

backup_folder "$SRC_DOCS" "$DEST_DOCS" "Documents"
backup_folder "$SRC_DL" "$DEST_DL" "Downloads"

echo "🎉 All backups finished successfully!"

