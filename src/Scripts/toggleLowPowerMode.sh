#! /usr/bin/bash

### ENABLES/DISABLES LOW POWER MODE


## Notes
# The sed command replaces the argument after s/^ with the argument after /
# Enabled = LPM enabled
# Disabled = LPM disabled


# Run by Favorites key F12 (Fn Lock Off)
# Changes various setting to limit performance. Only has effect when on battery.

file=/etc/tlp.conf

CPU_SCALING_GOVERNOR_ON_BAT_enabled=powersave
CPU_SCALING_GOVERNOR_ON_BAT_disabled=performance

CPU_ENERGY_PERF_POLICY_ON_BAT_enabled=power
CPU_ENERGY_PERF_POLICY_ON_BAT_disabled=balance_power

PLATFORM_PROFILE_ON_BAT_enabled=low-power
PLATFORM_PROFILE_ON_BAT_disabled=balanced

CPU_HWP_DYN_BOOST_ON_BAT_enabled=0
CPU_HWP_DYN_BOOST_ON_BAT_disabled=1

CPU_BOOST_ON_BAT_enabled=0
CPU_BOOST_ON_BAT_disabled=1

# Check the currently set state of LPM in tlp.conf then Toggle values
if grep -q "LPM=0" "$file"; then 
	echo "Currently disabled. Enabling..."
	sed -i "s/^LPM=0/LPM=1/" $file 

	sed -i "s/^CPU_SCALING_GOVERNOR_ON_BAT=$CPU_SCALING_GOVERNOR_ON_BAT_disabled/CPU_SCALING_GOVERNOR_ON_BAT=$CPU_SCALING_GOVERNOR_ON_BAT_enabled/" $file 
	sed -i "s/^CPU_ENERGY_PERF_POLICY_ON_BAT=$CPU_ENERGY_PERF_POLICY_ON_BAT_disabled/CPU_ENERGY_PERF_POLICY_ON_BAT=$CPU_ENERGY_PERF_POLICY_ON_BAT_enabled/" $file 
	sed -i "s/^PLATFORM_PROFILE_ON_BAT=$PLATFORM_PROFILE_ON_BAT_disabled/PLATFORM_PROFILE_ON_BAT=$PLATFORM_PROFILE_ON_BAT_enabled/" $file 
	sed -i "s/^CPU_HWP_DYN_BOOST_ON_BAT=$CPU_HWP_DYN_BOOST_ON_BAT_disabled/CPU_HWP_DYN_BOOST_ON_BAT=$CPU_HWP_DYN_BOOST_ON_BAT_enabled/" $file 
	sed -i "s/^CPU_BOOST_ON_BAT=$CPU_BOOST_ON_BAT_disabled/CPU_BOOST_ON_BAT=$CPU_BOOST_ON_BAT_enabled/" $file 

	sudo -u ehar DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 500 -i battery-level-20-symbolic "Low Power Mode Enabled" "Performance on battery may be affected"

else
	echo "Currently enabled. Disabling..."
	sed -i "s/^LPM=1/LPM=0/" $file 

	sed -i "s/^CPU_SCALING_GOVERNOR_ON_BAT=$CPU_SCALING_GOVERNOR_ON_BAT_enabled/CPU_SCALING_GOVERNOR_ON_BAT=$CPU_SCALING_GOVERNOR_ON_BAT_disabled/" $file 
	sed -i "s/^CPU_ENERGY_PERF_POLICY_ON_BAT=$CPU_ENERGY_PERF_POLICY_ON_BAT_enabled/CPU_ENERGY_PERF_POLICY_ON_BAT=$CPU_ENERGY_PERF_POLICY_ON_BAT_disabled/" $file 
	sed -i "s/^PLATFORM_PROFILE_ON_BAT=$PLATFORM_PROFILE_ON_BAT_enabled/PLATFORM_PROFILE_ON_BAT=$PLATFORM_PROFILE_ON_BAT_disabled/" $file 
	sed -i "s/^CPU_HWP_DYN_BOOST_ON_BAT=$CPU_HWP_DYN_BOOST_ON_BAT_enabled/CPU_HWP_DYN_BOOST_ON_BAT=$CPU_HWP_DYN_BOOST_ON_BAT_disabled/" $file 
	sed -i "s/^CPU_BOOST_ON_BAT=$CPU_BOOST_ON_BAT_enabled/CPU_BOOST_ON_BAT=$CPU_BOOST_ON_BAT_disabled/" $file 

	sudo -u ehar DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 500 -i battery-level-80-symbolic "Low Power Mode Disabled" "Balanced Performance"

fi

tlp start
