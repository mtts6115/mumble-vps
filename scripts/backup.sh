#!/usr/bin/env bash
# ==============================================================================
# Helper Script: Backup Mumble Server Database & Configuration
# ==============================================================================

set -euo pipefail

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/mumble_backup_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "[INFO] Creating Mumble backup: ${BACKUP_FILE}..."

# List files/folders to include if they exist
TARGETS=()
[ -d "./data" ] && TARGETS+=("./data")
[ -f "./.env" ] && TARGETS+=("./.env")
[ -f "./docker-compose.yml" ] && TARGETS+=("./docker-compose.yml")
[ -d "./config" ] && TARGETS+=("./config")

# Check native installation paths if docker data isn't present
if [ ${#TARGETS[@]} -eq 0 ]; then
    [ -f "/var/lib/mumble-server/mumble-server.sqlite" ] && TARGETS+=("/var/lib/mumble-server/mumble-server.sqlite")
    [ -f "/etc/mumble-server.ini" ] && TARGETS+=("/etc/mumble-server.ini")
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo "[ERROR] No data or configuration files found to back up!"
    exit 1
fi

tar -czf "$BACKUP_FILE" "${TARGETS[@]}"

echo "[SUCCESS] Backup created at: ${BACKUP_FILE}"

# Keep only the last 14 backups
find "$BACKUP_DIR" -type f -name "mumble_backup_*.tar.gz" -mtime +14 -exec rm -f {} +
echo "[INFO] Cleaned up backups older than 14 days."
