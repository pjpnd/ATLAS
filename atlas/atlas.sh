#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n\t'

CONFIG_FILE="/etc/atlas/atlas.conf"

log() {
  echo "$(date -u +"%Y-%m-%d %H:%M:%S UTC") [ATLAS $$] $*"
}

fatal() {
    log "FATAL: $*"
    exit 1
}

trap 'fatal "Script interrupted or failed on line $LINENO"' ERR INT TERM

[ -f "$CONFIG_FILE" ] || fatal "Config file not found: $CONFIG_FILE"
source "$CONFIG_FILE"

: "${output_dir:?Missing output_dir}"

HOSTNAME=${hostname_override:-$(hostname)}
OUTPUT_FILE="${output_dir}/$HOSTNAME"
TMP_FILE="/tmp/${HOSTNAME}.atlas.$$"

log "---BEGIN ATLAS TELEMETRY COLLECTION FOR $HOSTNAME---"

mkdir -p "$output_dir" || fatal "Failed to create output directory: $output_dir"

log "Writing results to $TMP_FILE"

{
    echo "Timestamp: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "Hostname: $HOSTNAME"
    echo "OS: $(source /etc/os-release && echo "$PRETTY_NAME")"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p)"
    echo "Last Boot: $(who -b | awk '{print $3, $4}')"
    echo "CPU: $(lscpu | awk -F ': +' '/Model name/ {print $2}' | xargs)"
    echo "GPU: $(command -v lspci >/dev/null && lspci | grep -i vga | head -n1 || echo 'N/A')"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $2 " total, " $3 " used, " $4 " free"}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $2 " total, " $3 " used, " $4 " available"}')"
    echo "Root Partition: $(df -h / | awk 'NR==2 { print $5 " used of " $2 }')"
    echo "IP Address: $(ip addr show | awk '/inet / && $2 !~ /^127\./ {print $2}' | cut -d/ -f1 | xargs)"
    echo "Logged Users: $(who | wc -l)"
    echo "Services Count: $(systemctl list-units --type=service --state=running | grep '\.service' | wc -l)"
    echo "NTP Status: $(timedatectl | awk -F ': +' '/System clock synchronized/ {print $2}' | xargs)"
    echo "System Load Average: $(uptime | awk -F'load average: ' '{print $2}')"
} > "$TMP_FILE" || fatal "Failed to write telemetry data"

mv "$TMP_FILE" "$OUTPUT_FILE" || fatal "Failed to move temp file to output file"

log "Results moved to $OUTPUT_FILE"

log "---ATLAS TELEMETRY COLLECTION COMPLETE---"
