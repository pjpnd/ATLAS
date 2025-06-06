#!/usr/bin/env bash


# Standard installer for ATLAS service

set -euo pipefail
IFS=$'\n\t'

log() {
    echo "[INSTALL] $*"
}

fatal() {
    echo "[FATAL] $*" >&2
    exit 1
}

install_file() {
    local src=$1
    local dest=$2
    local perm=${3:-}

    if [ ! -f "$src" ]; then
        fatal "Source file not found: $src"
    fi

    log "Installing $src to $dest"
    cp "$src" "$dest" || fatal "Failed to copy $src to $dest"

    if [ -n "$perm" ]; then
        chmod "$perm" "$dest" || fatal "Failed to set permissions $perm on $dest"
    fi
}

install_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        log "Creating directory $dir"
	mkdir -p "$dir" || fatal "Failed to create directory $dir"
    fi
}

log "Starting ATLAS installation"

# Directories
install_dir /etc/atlas
install_dir /usr/local/bin

# Config file
install_file ./atlas/atlas.conf /etc/atlas/atlas.conf 0644

# Script
install_file ./atlas/atlas.sh /usr/local/bin/atlas.sh 0755

# Systemd service files
install_file ./atlas/atlas.service /etc/systemd/system/atlas.service 0644 
install_file ./atlas/atlas.timer /etc/systemd/system/atlas.timer 0644

log "Reloading systemd daemon"
systemctl daemon-reload || fatal "Failed to reload systemd daemon"

log "Enabling atlas.timer"
systemctl enable atlas.timer || fatal "Failed to enable atlas.timer"

log "Starting atlas.timer"
systemctl start atlas.timer || fatal "Failed to start atlas.timer"

log "ATLAS installation complete"
