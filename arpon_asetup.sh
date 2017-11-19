#!/bin/bash

### BEGIN INIT INFO
# Provides:          arpon_auto
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: This is an script to automate the configuration of ArpOn
### END INIT INFO

# Author: ArenGamerz <arendevel@gmail.com>
# Version: 2.2.1

# ArpOn conf file
conf_file='/etc/arpon.conf'

# Colors
yellow=`tput setaf 3`
reset=`tput sgr0`
bold=`tput bold`
green=`tput setaf 2`


# Killing any running currently instance of arpon
killall -9 arpon 1>/dev/null 2>/dev/null

# Now depending on the network that we are connected to we setup the arpon.conf and start a new instance of arpon

function autosetup() {
	if grep -q "$1" "$conf_file"; then
		sed -i '/^#/! s/^/#/' "$conf_file"
		sed -i "/$1/ s|^#||" "$conf_file"
		arpon -i $2 -d -H 1>/dev/null 2>/dev/null
		echo "${bold}${green}Automatic setup succeed!${reset}"
	else
		arpon -i $2 -d -D 1>/dev/null 2>/dev/null
		echo "${bold}${yellow}WARNING: IP '$ip*' NOT FOUND IN arpon.conf file, so ArpOn is running in Dynamic Mode${reset}"
	fi
return 0
}

time=10
while true; do
	ip=$(ip addr | grep inet.*brd | sed 's/^.*inet //;s/ brd.*$//;s/^//;2,$ d;s/\.[[:digit:]]\+\/..$/./')
	iface=$(ip route | grep via | cut -d" " -f5)

	if [ -z "$ip" ] || [ -z "$iface" ]; then
		sleep "$time"
		time=$(($time+5))
		continue
	else
		autosetup "$ip" "$iface"
		break
	fi
done
