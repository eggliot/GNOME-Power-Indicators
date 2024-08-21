#! /usr/bin/bash

### ENABLES/DISABLES GUIDED MODE


# Triggered by Super Alt T and or cyclePowerModes.sh
# Throttles the CPU down to 75 for both AC and Battery 

file=/etc/tlp.conf

# Check the currently set state of THROTTLED in tlp.conf then Toggle values
if grep -q "THROTTLED=0" "$file"; then 
	echo "Currently disabled. Enabling..."
    sed -i "s/^THROTTLED=0/THROTTLED=1/" $file

	sed -i "s/^CPU_DRIVER_OPMODE_ON_BAT=active/CPU_DRIVER_OPMODE_ON_BAT=guided/" $file
	sed -i "s/^CPU_DRIVER_OPMODE_ON_AC=active/CPU_DRIVER_OPMODE_ON_AC=guided/" $file

	sudo -u ehar DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 500 -i power-profile-power-saver-symbolic "Throttled Mode Enabled" "CPU Limited to 75%"


else
	echo "Currently enabled. Disabling..."
    sed -i "s/^THROTTLED=1/THROTTLED=0/" $file

	sed -i "s/^CPU_DRIVER_OPMODE_ON_BAT=guided/CPU_DRIVER_OPMODE_ON_BAT=active/" $file
	sed -i "s/^CPU_DRIVER_OPMODE_ON_AC=guided/CPU_DRIVER_OPMODE_ON_AC=active/" $file

	sudo -u ehar DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 500 -i power-profile-performance-symbolic "Throttled Mode Disabled" "CPU Not Limited"

fi


tlp start
