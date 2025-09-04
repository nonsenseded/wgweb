#!/bin/bash

# ==============================================================================
# Uninstallation Script for WireGuard Web UI
# This script automates the removal of the WireGuard server and web UI components.
# ==============================================================================

# Function to stop and disable services
stop_services() {
    systemctl stop wg-web.service &>/dev/null
    systemctl disable wg-web.service &>/dev/null
    systemctl stop wg-quick@wg0.service &>/dev/null
    systemctl disable wg-quick@wg0.service &>/dev/null
}

# Function to remove files and directories
remove_files() {
    rm -f /etc/systemd/system/wg-web.service
    rm -f /etc/systemd/system/multi-user.target.wants/wg-quick@wg0.service
    rm -rf /etc/wireguard
    rm -rf /home/wgweb
    rm -f /etc/sysctl.d/wg.conf
}

# Function to remove firewall rules
remove_firewall_rules() {
    if command -v ufw &>/dev/null; then
        ufw delete allow 51820/udp &>/dev/null
        ufw delete allow 80/tcp &>/dev/null
    fi
}

# Main uninstallation process
echo -e "Uninstalling WireGuard Web UI and server..."

stop_services
remove_files
remove_firewall_rules

echo -e "Uninstallation complete."