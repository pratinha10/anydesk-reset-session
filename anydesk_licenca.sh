#!/bin/bash

echo "Resetting AnyDesk..."

# Checks if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Please, run as root (sudo)." 
   exit 1
fi

stop_any() {
    echo "Stopping AnyDesk..."
    systemctl stop anydesk
    pkill -f anydesk
}

start_any() {
    echo "Starting AnyDesk..."
    systemctl start anydesk
    sleep 2
    # Tries to start manually if needed
    command -v anydesk >/dev/null && nohup anydesk >/dev/null 2>&1 &
}

TEMP_DIR="/tmp/anydesk_reset"
USER_CONF="$HOME/.anydesk/user.conf"
SERVICE_CONF_SYS="/etc/anydesk/service.conf"
SERVICE_CONF_USER="$HOME/.anydesk/service.conf"
THUMB_DIR="$HOME/.anydesk/thumbnails"

stop_any

mkdir -p "$TEMP_DIR"

# Backup user files
cp -f "$USER_CONF" "$TEMP_DIR/user.conf" 2>/dev/null
cp -r "$THUMB_DIR" "$TEMP_DIR/thumbnails" 2>/dev/null

# Remove configurations
rm -f "$SERVICE_CONF_SYS" "$SERVICE_CONF_USER"
rm -rf "$HOME/.anydesk"/*

start_any

# Waits for system.conf to appear with a valid ID (simulation)
while ! grep -q "ad.anynet.id=" /etc/anydesk/system.conf 2>/dev/null; do
    sleep 1
done

# Restore data
stop_any
mkdir -p "$HOME/.anydesk/thumbnails"
cp -f "$TEMP_DIR/user.conf" "$USER_CONF" 2>/dev/null
cp -r "$TEMP_DIR/thumbnails/"* "$HOME/.anydesk/thumbnails/" 2>/dev/null

rm -rf "$TEMP_DIR"

start_any

echo "*********"
echo "Completed."