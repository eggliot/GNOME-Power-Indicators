#! /usr/bin/bash

#Only options are performance and powersave. Could enable if wanted but there is minimal need i think.
# CPU_SCALING_GOVERNOR_ON_AC_enabled=performance
# CPU_SCALING_GOVERNOR_ON_AC_disabled=powersave


# Run by cyclePowerModes.sh ONLY AC
# Changes the platform profile when on AC to allow for a bit more performance and hotter operation.

file=/etc/tlp.conf

PLATFORM_PROFILE_ON_AC_enabled=performance
PLATFORM_PROFILE_ON_AC_disabled=balanced

# Super Alt P runs this - Toggles Performance Mode
if grep -q "PERF=0" "$file"; then 
	echo "Currently disabled. Enabling..."
    sed -i "s/^PERF=0/PERF=1/" $file

	# sed -i "s/^CPU_SCALING_GOVERNOR_ON_AC=$CPU_SCALING_GOVERNOR_ON_AC_disabled/CPU_SCALING_GOVERNOR_ON_AC=$CPU_SCALING_GOVERNOR_ON_AC_enabled/" tlp.conf 
	# sed -i "s/^CPU_ENERGY_PERF_POLICY_ON_AC=$CPU_ENERGY_PERF_POLICY_ON_AC_disabled/CPU_ENERGY_PERF_POLICY_ON_AC=$CPU_ENERGY_PERF_POLICY_ON_AC_enabled/" tlp.conf 
	sed -i "s/^PLATFORM_PROFILE_ON_AC=$PLATFORM_PROFILE_ON_AC_disabled/PLATFORM_PROFILE_ON_AC=$PLATFORM_PROFILE_ON_AC_enabled/" $file
	# sed -i "s/^CPU_HWP_DYN_BOOST_ON_AC=$CPU_HWP_DYN_BOOST_ON_AC_disabled/CPU_HWP_DYN_BOOST_ON_AC=$CPU_HWP_DYN_BOOST_ON_AC_enabled/" tlp.conf 
	# sed -i "s/^CPU_BOOST_ON_AC=$CPU_BOOST_ON_AC_disabled/CPU_BOOST_ON_AC=$CPU_BOOST_ON_AC_enabled/" tlp.conf 


	sudo -u ehar DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 500 -i power-profile-performance-symbolic "Performance Mode Enabled" "Increased Performance on AC"

else
	echo "Currently enabled. Disabling..."
    sed -i "s/^PERF=1/PERF=0/" $file

	# sed -i "s/^CPU_SCALING_GOVERNOR_ON_AC=$CPU_SCALING_GOVERNOR_ON_AC_enabled/CPU_SCALING_GOVERNOR_ON_AC=$CPU_SCALING_GOVERNOR_ON_AC_disabled/" tlp.conf 
	# sed -i "s/^CPU_ENERGY_PERF_POLICY_ON_AC=$CPU_ENERGY_PERF_POLICY_ON_AC_enabled/CPU_ENERGY_PERF_POLICY_ON_AC=$CPU_ENERGY_PERF_POLICY_ON_AC_disabled/" tlp.conf 
	sed -i "s/^PLATFORM_PROFILE_ON_AC=$PLATFORM_PROFILE_ON_AC_enabled/PLATFORM_PROFILE_ON_AC=$PLATFORM_PROFILE_ON_AC_disabled/" $file
	# sed -i "s/^CPU_HWP_DYN_BOOST_ON_AC=$CPU_HWP_DYN_BOOST_ON_AC_enabled/CPU_HWP_DYN_BOOST_ON_AC=$CPU_HWP_DYN_BOOST_ON_AC_disabled/" tlp.conf 
	# sed -i "s/^CPU_BOOST_ON_AC=$CPU_BOOST_ON_AC_enabled/CPU_BOOST_ON_AC=$CPU_BOOST_ON_AC_disabled/" tlp.conf 

	sudo -u ehar DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 500 -i power-profile-balanced-symbolic "Performance Mode Disabled" "Lower Performance on AC"


fi

tlp start
