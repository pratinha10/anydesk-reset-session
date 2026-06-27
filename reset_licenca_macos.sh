#!/bin/bash

SERVICE="com.anydesk.anydesk"    # example of service bundle ID
APP="/Applications/AnyDesk.app"
CONFIG_DIR="$HOME/Library/Application Support/AnyDesk"
TEMP_DIR="/tmp/anydesk_temp"

banner() {
    clear
    echo "  ============================================================"
    echo "                     AnyDesk Reset Tool"
    echo "            Resets the free-tier connection license"
    echo "                     by pratinha10"
    echo "  ============================================================"
    echo
}

# ================================
# Function: Stops the service and the app
# ================================
stop_any() {
    if launchctl list | grep -q "$SERVICE"; then
        sudo launchctl stop "$SERVICE" >/dev/null 2>&1
    fi
    pkill -f AnyDesk 2>/dev/null
}

# ================================
# Function: Starts the application
# ================================
start_any() {
    if [ -d "$APP" ]; then
        open "$APP"
    fi
}

# ================================
# Saves and restores configuration
# ================================
backup_config() {
    mkdir -p "$TEMP_DIR"
    cp -R "$CONFIG_DIR/user.conf" "$TEMP_DIR/" 2>/dev/null
}

restore_config() {
    cp -R "$TEMP_DIR/user.conf" "$CONFIG_DIR/" 2>/dev/null
    rm -rf "$TEMP_DIR"
}

# ================================
# Main flow
# ================================
banner

echo "  [1/5] Stopping AnyDesk..."
stop_any
echo "        [OK] Service stopped."
echo

echo "  [2/5] Backing up your settings..."
backup_config
echo "        [OK] User config saved."
echo

echo "  [3/5] Clearing AnyDesk data and generating a new ID..."
rm -rf "$CONFIG_DIR/thumbnails"

start_any

echo -n "        Waiting for AnyDesk to assign a new ID"
TIMEOUT=30
COUNTER=0
while ! grep -q "ad.anynet.id=" "$CONFIG_DIR/system.conf" 2>/dev/null; do
    echo -n "."
    sleep 1
    COUNTER=$((COUNTER+1))
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo
        echo "        [WARN] Timeout waiting for a new ID."
        break
    fi
done
if [ $COUNTER -lt $TIMEOUT ]; then
    echo
    echo "        [OK] New ID generated."
fi
echo

echo "  [4/5] Restoring your settings..."
stop_any
restore_config
echo "        [OK] Settings restored."
echo

echo "  [5/5] Starting AnyDesk..."
start_any
echo "        [OK] AnyDesk is running."
echo

echo "  ============================================================"
echo "                     Reset completed!"
echo "    AnyDesk is ready to use with a fresh free-tier license."
echo "  ------------------------------------------------------------"
echo "                  Tool made by pratinha10"
echo "  ============================================================"
echo