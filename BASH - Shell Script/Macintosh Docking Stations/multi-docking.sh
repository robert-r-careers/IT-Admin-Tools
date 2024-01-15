#!/bin/bash

# Docking Station MacAddr's Array # Current Hardware: CalDigit USC-C HDMI Dock
mac_address=("10:00:00:00:00:01 20:00:00:00:00:02 30:00:00:00:00:03 40:00:00:00:00:04 50:00:00:00:00:05")
# Search Domains
search_dns1="AUTH.DOMAIN.LOCAL" search_dns2="RESCS.DOMAIN.LOCAL" search_dns3="DOMAIN.LOCAL" search_dns4="INT.DOMAIN.IT.NET"
# DNS Servers 
city1_dns="10.10.5.1" city2_dns="10.10.5.2" city3_dns="10.10.5.3" city4_dns="10.10.5.4" city5_dns="10.10.5.4" dns1="10.10.5.5" dns2="10.10.5.6"
# city1 IP Variables
city1_ip="191.168.1.10" city1_mask="255.255.255.0" city1_gate="191.168.10.1"
# City 2 IP Variables
city2_ip="192.168.10.10" city2_mask="255.255.255.0" city2_gate="192.168.10.1"
# 'City 3 IP Variables
city3_ip="193.168.10.10" city3_mask="255.255.255.0" city3_gate="193.168.10.1"
# City 4 IP Variables
city4_ip="193.168.10.10" city4_mask="255.255.255.0" city4_gate="193.168.10.1"
# City 5 IP Variables
city5_ip="192.168.10.64.50" city5_mask="255.255.255.128" city5_gate="192.168.10.64.1"

#######################################################################################################################
# Example Case/Template #

# ADD NEW MACADDR HERE) 
#      if [ "$(networksetup -getcurrentlocation)" != 'EXAMPLE LOCATION NAME' ];
#      then 
#          networksetup -switchtolocation 'EXAMPLE LOCATION NAME' >> /dev/null
#      fi
#
#     ## If EXAMPLE LOCATION does not exisit, create it and switch to it
#      if [ $? != 0 ]; 
#      then
#          sudo networksetup -createlocation 'EXAMPLE LOCATION NAME' populate
#          networksetup -switchtolocation 'EXAMPLE LOCATION NAME' up >> /dev/null
#      fi
#   
#      # Get current IP Configuration for adapter/location, creates varibles> $ip , $mask , $gw
#     ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
#      mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
#      gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')
#      
#      ## If current IP information matches EXAMPLE LOCATION IP Varibles do nothing, if they do not match change them to the configuration below
#      if [ "$ip" == "$example_location_ip" ] && [ "$mask" == "$eample_location_mask" ] && [ "$gw" == "example_$location_gate" ]
#      then
#          break
#      else
#          sudo networksetup -setdnsservers "$hardwareports" "$location_dns" "$dns1" "$dns2"
#          sudo networksetup -setsearchdomains "$hardwareports" "$searchdns1" "$searchdns2" "$searchdns3" "$searchdns4"
#          sudo networksetup -setmanual "$hardwareports" "$example_location_ip" "$example_location_mask" "$example_location_gate"
#      fi
#
#      break
#      ;;

# End of Example Case #
#######################################################################################################################


#######################################################################################################################
## Do not edit anything below this line. Do not edit anything below this line. Do not edit anything below this line. ##
#######################################################################################################################

# Case Statement= For MacAddr in MacAddr Array do the following:
for mac in ${mac_address[*]}; do
# Get MacAddr's of connected Hardware and see if it matches one from the MacAddr array, if it does apply the matching case
  if [ "$mac" == "$(networksetup -listallhardwareports | grep -o "$mac" )" ]; then
# Lists all hardware ports of connected network hardware, compares hardware MacAddr to MacAddr array, selects line "Hardware Port:",
# cuts at deliminator ":" and removes white spaces from begininng and end. Creates variable output for hardware port name (i.e 'USB 10/100/1000 LAN')
hardwareports=$(networksetup -listallhardwareports | grep -B 2 "$mac" | sed -n '1 P' | cut -f 2 -d ":" | xargs)
    case "$mac" in

# City 1 Case
    8c:ec:4b:12:91:41) 
      # Check current location, if current location is not City 1 then swithch to it, if current location is City 1 do nothing 
      if [ "$(networksetup -getcurrentlocation)" != 'City 1' ];
      then 
          networksetup -switchtolocation 'City 1' >> /dev/null
      fi

      ## If City 1 does not exisit, create it and switch to it
       if [ $? != 0 ]; 
      then
          sudo networksetup -createlocation 'City 1' populate
          networksetup -switchtolocation 'City 1' up >> /dev/null
      fi
   
      # Get current IP Configuration for adapter/location, creates varibles> $ip , $mask , $gw 
      ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
      mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
      gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')
      
      ## If current IP information matches City 1 IP Varibles do nothing, if they do not match change them to the configuration below 
      if [ "$ip" == "$city1_ip" ] && [ "$mask" == "$city1_mask" ] && [ "$gw" == "$city1_gate" ]
      then
          break
      else
          sudo networksetup -setdnsservers "$hardwareports" "$city1_dns" "$dns1" "$dns2"
          sudo networksetup -setsearchdomains "$hardwareports" "$searchdns1" "$searchdns2" "$searchdns3" "$searchdns4"
          sudo networksetup -setmanual "$hardwareports" "$city1_ip" "$city1_mask" "$city1_gate"
      fi

      break
      ;;

# City 2 Case
    64:4b:f0:33:14:e0)
      if [ "$(networksetup -getcurrentlocation)" != 'City 2' ];
      then
          networksetup -switchtolocation 'City 2' >> /dev/null
      fi

      if [ $? != 0 ]; 
      then
          sudo networksetup -createlocation 'City 2' populate
          networksetup -switchtolocation 'City 2' up >> /dev/null
      fi

      ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
      mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
      gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')

      if [ "$ip" == "$city2_ip" ] && [ "$mask" == "$city2_mask" ] && [ "$gw" == "$city2_gate" ]
      then
          break
      else
          sudo networksetup -setdnsservers "$hardwareports" "$city2_dns" "$dns1" "$dns2"
          sudo networksetup -setsearchdomains "$hardwareports" "$searchdns1" "$searchdns2" "$searchdns3" "$searchdns4"
          sudo networksetup -setmanual "$hardwareports" "$city2_ip" "$city2_mask" "$city2_gate"
      fi

      break
      ;;

# City 3 Case
    64:4b:f0:33:0a:59)
      if [ "$(networksetup -getcurrentlocation)" != 'City 3' ];
      then
          networksetup -switchtolocation 'City 3' >> /dev/null
      fi

      if [ $? != 0 ]; 
      then
          sudo networksetup -createlocation 'City 3' populate
          networksetup -switchtolocation 'City 3' up >> /dev/null
      fi

      ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
      mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
      gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')

      if [ "$ip" == "$city3_ip" ] && [ "$mask" == "$city3_mask" ] && [ "$gw" == "$city3_gate" ]
      then 
          break
      else   
          sudo networksetup -setdnsservers "$hardwareports" "$dns1" "$dns2"
          sudo networksetup -setsearchdomains "$hardwareports" "$searchdns1" "$searchdns2" "$searchdns3" "$searchdns4"
          sudo networksetup -setmanual "$hardwareports" "$city3_ip" "$city3_mask" "$city3_gate"
      fi

      break
      ;;

# City 4 Case 
    64:4b:f0:33:0a:50)
      if [ "$(networksetup -getcurrentlocation)" != 'City 4' ];
      then 
          networksetup -switchtolocation 'City 4' >> /dev/null
      fi

      if [ $? != 0 ]; 
      then
          sudo networksetup -createlocation 'City 4' populate
          networksetup -switchtolocation 'City 4' up >> /dev/null
      fi

      ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
      mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
      gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')

      if [ "$ip" == "$city4_ip" ] && [ "$mask" == "$city4_mask" ] && [ "$gw" == "$city4_gate" ]
      then 
          break
      else   

          sudo networksetup -setdnsservers "$hardwareports" "$city4_dns" "$dns1" "$dns2"
          sudo networksetup -setsearchdomains "$hardwareports" "$searchdns1" "$searchdns2" "$searchdns3" "$searchdns4"
          sudo networksetup -setmanual "$hardwareports" "$city4_ip" "$city4_mask" "$city4_gate"

      fi 

      break
      ;;

# City 5 Case
    64:4b:f0:33:0a:4b)
      if [ "$(networksetup -getcurrentlocation)" != 'City 5' ];
      then 
          networksetup -switchtolocation 'City 5' >> /dev/null
      fi

      if [ $? != 0 ]; 
      then
          sudo networksetup -createlocation 'City 5' populate
          networksetup -switchtolocation 'City 5' up >> /dev/null
      fi

      ip=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '1 P')
      mask=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '2 P')
      gw=$(networksetup -getinfo "$hardwareports" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n '3 P')

      if [ "$ip" == "$city5_ip" ] && [ "$mask" == "$city5_mask" ] && [ "$gw" == "$city5_gate" ]
      then 
          break
      else   
          sudo networksetup -setdnsservers "$hardwareports" "$city5_dns" "$dns1" "$dns2"
          sudo networksetup -setsearchdomains "$hardwareports" "$searchdns1" "$searchdns2" "$searchdns3" "$searchdns4"
          sudo networksetup -setmanual "$hardwareports" "$city5_ip" "sf_mask" "sf_gate"

      fi

      break
      ;;

    esac
# Switch to Automatic Profile if no MacAddr connected
  else
      if [ "$(networksetup -getcurrentlocation)" != 'Automatic' ];
      then 
          networksetup -switchtolocation 'Automatic' >> /dev/null
      fi
      if [ $? != 0 ]; 
      then
          sudo networksetup -createlocation "Automatic" populate
          networksetup -switchtolocation "Automatic" up >> /dev/null
      fi
fi

done

# OSX launchd configuration
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# 	<dict>
# 		<key>Label</key>
#		<string>local.detectdock</string>
#		<key>Program</key>
#		<string>/Library/Scripts/docking_station_switch.sh</string>
#		<key>StartInterval</key>
#		<integer>300</integer>
#		<true/>
#	</dict>
# </plist>
