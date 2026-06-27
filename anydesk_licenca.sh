#!/bin/bash

TEMP_DIR="/tmp/anydesk_reset"
USER_CONF="$HOME/.anydesk/user.conf"
SERVICE_CONF_SYS="/etc/anydesk/service.conf"
SERVICE_CONF_USER="$HOME/.anydesk/service.conf"
THUMB_DIR="$HOME/.anydesk/thumbnails"

banner() {
    clear
    echo "  ============================================================"
    echo "                     AnyDesk Reset Tool"
    echo "            Resets the free-tier connection license"
    echo "                     by pratinha10"
    echo "  ============================================================"
    echo
}

stop_any() {
    systemctl stop anydesk >/dev/null 2>&1
    pkill -f anydesk >/dev/null 2>&1
}

start_any() {
    systemctl start anydesk >/dev/null 2>&1
    sleep 2
    command -v anydesk >/dev/null && nohup anydesk >/dev/null 2>&1 &
}

banner

# Checks if running as root
if [[ $EUID -ne 0 ]]; then
    echo "  [ERROR] This script must be run as root."
    echo
    echo "  Try: sudo ./anydesk_licenca.sh"
    echo
    exit 1
fi

echo "  [1/5] Stopping AnyDesk..."
stop_any
echo "        [OK] Service stopped."
echo

echo "  [2/5] Removing license configuration..."
rm -f "$SERVICE_CONF_SYS" "$SERVICE_CONF_USER"
echo "        [OK] Old license files removed."
echo

echo "  [3/5] Backing up your settings..."
mkdir -p "$TEMP_DIR"
cp -f "$USER_CONF" "$TEMP_DIR/user.conf" 2>/dev/null
cp -r "$THUMB_DIR" "$TEMP_DIR/thumbnails" 2>/dev/null
echo "        [OK] User config and thumbnails saved."
echo

echo "  [4/5] Clearing AnyDesk data and generating a new ID..."
rm -rf "$HOME/.anydesk"/*

start_any

echo -n "        Waiting for AnyDesk to assign a new ID"
while ! grep -q "ad.anynet.id=" /etc/anydesk/system.conf 2>/dev/null; do
    echo -n "."
    sleep 1
done
echo
echo "        [OK] New ID generated."
echo

echo "  [5/5] Restoring your settings..."
stop_any
mkdir -p "$HOME/.anydesk/thumbnails"
cp -f "$TEMP_DIR/user.conf" "$USER_CONF" 2>/dev/null
cp -r "$TEMP_DIR/thumbnails/"* "$HOME/.anydesk/thumbnails/" 2>/dev/null
rm -rf "$TEMP_DIR"

start_any
echo "        [OK] Settings restored."
echo

echo "  ============================================================"
echo "                     Reset completed!"
echo "    AnyDesk is ready to use with a fresh free-tier license."
echo "  ------------------------------------------------------------"
echo "                  Tool made by pratinha10"
echo "  ============================================================"
echo