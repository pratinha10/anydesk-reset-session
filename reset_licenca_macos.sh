#!/bin/bash

SERVICE="com.anydesk.anydesk"    # example of service bundle ID
APP="/Applications/AnyDesk.app"
CONFIG_DIR="$HOME/Library/Application Support/AnyDesk"
TEMP_DIR="/tmp/anydesk_temp"

# ================================
# Function: Stops the service and the app
# ================================
stop_any() {
    echo "Stopping service and application..."

    # Stops the service if it exists
    if launchctl list | grep -q "$SERVICE"; then
        sudo launchctl stop "$SERVICE"
        echo "Service stopped."
    else
        echo "Service not found."
    fi

    # Kills the AnyDesk process if it is running
    pkill -f AnyDesk 2>/dev/null
}

# ================================
# Function: Starts the application
# ================================
start_any() {
    echo "Starting AnyDesk..."

    if [ -d "$APP" ]; then
        open "$APP"
        echo "Application started."
    else
        echo "Application not found at $APP"
    fi
}

# ================================
# Saves and restores configuration
# ================================
backup_config() {
    mkdir -p "$TEMP_DIR"
    cp -R "$CONFIG_DIR/user.conf" "$TEMP_DIR/" 2>/dev/null
    echo "Configuration temporarily saved."
}

restore_config() {
    cp -R "$TEMP_DIR/user.conf" "$CONFIG_DIR/" 2>/dev/null
    rm -rf "$TEMP_DIR"
    echo "Configuration restored."
}

# ================================
# Main flow
# ================================
stop_any
backup_config

# Here you could clear thumbnails or other temporary files
rm -rf "$CONFIG_DIR/thumbnails"

start_any

# Didactic example of waiting for something in system.conf
# (safe loop with timeout)
TIMEOUT=30
COUNTER=0
while ! grep -q "ad.anynet.id=" "$CONFIG_DIR/system.conf" 2>/dev/null; do
    sleep 1
    COUNTER=$((COUNTER+1))
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "Timeout waiting for system.conf"
        break
    fi
done

stop_any
restore_config
start_any

echo "*********"
echo "Completed."