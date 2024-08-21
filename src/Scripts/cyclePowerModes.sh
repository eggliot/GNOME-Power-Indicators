#! /usr/bin/bash

## Should read what the current mode is set to - this will be a value set in tlp.conf 
## After getting the current value just progress to the next one
#
#no ^
# this instead: Check if on AC, if so run the AC script (toggle Performance Mode) which sets TLP values to performance mode ON_AC then starts tlp (restart)
# if on battery it runs the Throttle script which sets TLP values to throttle the CPU to 75% on battery

# These are persistant between power mode switches - ie next time i go back on battery it will still be throttled - how can i make this not 
# to fix that i need to echo values not write to TLP. TLP shoul dstore the default values for AC and BAT, echoing will only temporarily change them i think
# or i just make a UDEV hook to set TLP back to what it was for the defaults
# lets check if echoing is persistant
# update i am unable to echo to cpu energy performance preference it is busy and permission is denied so i guess i will have to do the UDEV route

## smth like the below would work where the two scripts reset TLP to the defaults for BAT and AC
# /etc/udev/rules.d/99-battery.rules

# SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/local/bin/on_battery.sh"
# SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/local/bin/on_ac.sh"


## Old ideas and thinking above ^

# SO WHAT THIS ALL DOES
# When Fn + B is pressed that runs this script which if on AC will run togglePerformanceMode.sh to change the platform profile in /etc/tlpconf.
# If on Battery it will run toggleThrottledMode.sh which will throttle down the PC when on either Battery or AC. It sets the OPMODE to guided forcing the usage of frequency scaling.

powerState=$(cat /sys/class/power_supply/AC/online) ## Returns 0 if running on battery power, 1 if on AC
echo "$powerState"


if [ "$powerState" -eq 1 ]; then
    echo "Connected to AC"
   
    nohup "/home/ehar/Documents/Scripts/togglePerformanceMode.sh"


else   
    echo "Connected to Battery"

    nohup "/home/ehar/Documents/Scripts/toggleLowPowerMode.sh"
fi
