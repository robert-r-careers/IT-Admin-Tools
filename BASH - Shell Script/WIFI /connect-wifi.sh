#!/bin/bash

echo "Checking Network Manager Status"

if ! nmcli radio wifi &>/dev/null; then
    echo "Starting Network Manager"
    systemctl enable NetworkManager &>/dev/null
    systemctl start NetworkManager &>/dev/null
    wait $!
else
    echo "Network Manager is already running"
fi

echo "Checking Radio Wifi Status"

if [ "$(nmcli radio wifi)" != 'enabled' ]; then
    echo "Starting Radio Wifi"
    nmcli radio wifi on
    wait $!
else
    echo "Radio Wifi is already enabled"
fi

echo "Looking for Wifi Networks"

network_list=$(nmcli dev wifi list | sort -k 7,7)

# Add line numbers to the network list
numbered_network_list=$(echo "$network_list" | awk '{print NR, $0}')

echo "$numbered_network_list"

# Present a menu for the user to select a Wi-Fi network
read -p "Enter the number of the Wi-Fi network you want to connect to: " network_number

# Extract the selected SSID from the user's input
selected_network=$(echo "$numbered_network_list" | awk -v num="$network_number" '{gsub(/^[0-9]+ \*? /, ""); if (NR==num) print $1}')

# Connect to the selected network
if [ -n "$selected_network" ]; then
    nmcli --ask dev wifi connect "$selected_network"
else
    echo "Error: No valid network selected."
fi
