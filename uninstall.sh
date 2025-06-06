#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[UNINSTALL] $*"
}

fatal() {
  echo "[FATAL] $*" >&2
  exit 1
}

remove_file() {
  local file=$1
  if [ -e "$file" ]; then
    log "Removing $file"
    rm -f "$file" || fatal "Failed to remove $file"
  else
    log "File $file does not exist, skipping"
  fi
}

log "Stopping atlas.timer and atlas.service"
systemctl stop atlas.timer atlas.service || log "Failed to stop services or services not running"
systemctl disable atlas.timer atlas.service || log "Failed to disable services or services not enabled"

log "Reloading systemd daemon"
systemctl daemon-reload || fatal "Failed to reload systemd daemon"

remove_file /etc/atlas/atlas.conf
remove_file /usr/local/bin/atlas.sh
remove_file /etc/systemd/system/atlas.service
remove_file /etc/systemd/system/atlas.timer

log "ATLAS uninstall complete"

