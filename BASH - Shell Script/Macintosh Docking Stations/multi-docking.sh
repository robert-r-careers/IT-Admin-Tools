#!/bin/bash

# Docking Station MacAddr's Array
mac_address=("10:00:00:00:00:01" "20:00:00:00:00:02" "30:00:00:00:00:03" "40:00:00:00:00:04" "50:00:00:00:00:05")

# Search Domains
search_dns1="AUTH.DOMAIN.LOCAL" search_dns2="RESCS.DOMAIN.LOCAL" search_dns3="DOMAIN.LOCAL" search_dns4="INT.DOMAIN.IT.NET"

# DNS Servers
city1_dns="10.10.5.1" city2_dns="10.10.5.2" city3_dns="10.10.5.3" city4_dns="10.10.5.4" city5_dns="10.10.5.4" dns1="10.10.5.5" dns2="10.10.5.6"

# City 1 IP Variables
city1_ip="191.168.1.10" city1_mask="255.255.255.0" city1_gate="191.168.10.1"

# City 2 IP Variables
city2_ip="192.168.10.10" city2_mask="255.255.255.0" city2_gate="192.168.10.1"

# City 3 IP Variables
city3_ip="193.168.10.10" city3_mask="255.255.255.0" city3_gate="193.168.10.1"

# City 4 IP Variables
city4_ip="193.168.10.10" city4_mask="255.255.255.0" city4_gate="193.168.10.1"

# City 5 IP Variables
city5_ip="192.168.10.64.50" city5_mask="255.255.255.128" city5_gate="192.168.10.64.1"

# ...

# Loop through each MacAddr in the array
for mac in "${mac_address[@]}"; do
    # Check if the MacAddr is connected
    if [ "$(networksetup -listallhardwareports | grep -o "$mac")" ]; then
        hardwareports=$(networksetup -listallhardwareports | grep -B 2 "$mac" | sed -n '1 P' | cut -f 2 -d ":" | xargs)
        
        case "$mac" in
            # City 1 Case
            8c:ec:4b:12:91:41)
                location_name='City 1'
                location_ip="$city1_ip"
                location_mask="$city1_mask"
                location_gate="$city1_gate"
                location_dns="$city1_dns"
                ;;

            # City 2 Case
            64:4b:f0:33:14:e0)
                location_name='City 2'
                location_ip="$city2_ip"
                location_mask="$city2_mask"
                location_gate="$city2_gate"
                location_dns="$city2_dns"
                ;;

            # City 3 Case
            64:4b:f0:33:0a:59)
                location_name='City 3'
                location_ip="$city3_ip"
                location_mask="$city3_mask"
                location_gate="$city3_gate"
                location_dns="$dns1"
                ;;

            # City 4 Case
            64:4b:f0:33:0a:50)
                location_name='City 4'
                location_ip="$city4_ip"
                location_mask="$city4_mask"
                location_gate="$city4_gate"
                location_dns="$city4_dns"
                ;;

            # City 5 Case
            64:4b:f0:33:0a:4b)
                location_name='City 5'
                location_ip="$city5_ip"
                location_mask="$city5_mask"
                location_gate="$city5_gate"
                location_dns="$city5_dns"
                ;;

            *)
                # Default case if MacAddr doesn't match any
                location_name='Automatic'
                location_ip=""
                location_mask=""
                location_gate=""
                location_dns=""
                ;;
        esac

        # Check current location
        if [ "$(networksetup -getcurrentlocation)" != "$location_name" ]; then
            networksetup -switchtolocation "$location_name" >> /dev/null
        fi

        # If location does not exist, create and switch to it
        if [ $? != 0 ]; then
            sudo networksetup -createlocation "$location_name" populate
            networksetup -switchtolocation "$location_name" up >> /dev/null
        fi

        # Get current IP Configuration for adapter/location
        ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
        mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
        gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')

        # If current IP information does not match location IP variables, change configuration
        if [ "$ip" != "$location_ip" ] || [ "$mask" != "$location_mask" ] || [ "$gw" != "$location_gate" ]; then
            sudo networksetup -setdnsservers "$hardwareports" $location_dns
            sudo networksetup -setsearchdomains "$hardwareports" $search_dns1 $search_dns2 $search_dns3 $search_dns4
            sudo networksetup -setmanual "$hardwareports" "$location_ip" "$location_mask" "$location_gate"
        fi

        break
    fi
done

# Default case if no MacAddr connected
if [ "$(networksetup -getcurrentlocation)" != 'Automatic' ]; then
    networksetup -switchtolocation 'Automatic' >> /dev/null
fi
done
