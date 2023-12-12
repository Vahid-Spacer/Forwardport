#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# User must run the script as root
 Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   sleep .5 
   sudo "$0" "$@"
   exit 1
fi

echo "Running as root..."
sleep .5
clear

distro=$(awk '/DISTRIB_ID=/' /etc/*-release | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
thisServerIP=$(ip a s|sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
networkInterfaceName=$(ip -o -4 route show to default | awk '{print $5}')

if [[ $distro != "ubuntu" ]]; then
	echo "distro not supported please use ubuntu"
	exit 1
fi
apt --fix-broken install -y
while true; do
    clear
    echo -e "${BLUE}|${NC}                        B Y                      ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}                 D E V S P A C E X               ${BLUE}|${NC}"
    echo -e "${BLUE}|            ---------------------------           |${NC}"
    echo -e "${BLUE}|                      ${GREEN}Main Menu${BLUE}                   |${NC}"
    echo -e "${YELLOW}+--------------------------------------------------+${NC}"
    echo -e"Select one of the following options"
    echo -e"   ${YELLOW} 1.${NC} ${GREEN} Server tunnel${NC}"
    echo -e"   ${YELLOW} 2.${NC} ${GREEN} Remove the tunnel${NC}"
    echo -e"   ${YELLOW} 3.${NC} ${GREEN} View the Forwarded IP${NC}"
    echo -e"   ${YELLOW} 4.${NC} ${GREEN} SSL cert"
    echo -e"   ${YELLOW} 5.${NC} ${GREEN} Exit"
    echo -e "${YELLOW}+--------------------------------------------------+${NC}"
    echo -e ""
    read -p "Please select one [1-2-3-4-5]: " choice 

case $choice in
1)
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -I PREROUTING -p tcp --dport 810 -j DNAT --to-destination "$thisServerIP"
    iptables -t nat -I PREROUTING -p udp --dport 810 -j DNAT --to-destination "$thisServerIP"
    iptables -t nat -I PREROUTING -p tcp --dport 4143 -j DNAT --to-destination "$thisServerIP"
    iptables -t nat -I PREROUTING -p udp --dport 4143 -j DNAT --to-destination "$thisServerIP"
    iptables -t nat -I PREROUTING -p tcp --dport 22 -j DNAT --to-destination "$thisServerIP"
    echo "Enter foreign server IP:"
    read -r foreignVPSIP
    iptables -t nat -A PREROUTING -j DNAT --to-destination "$foreignVPSIP"
    iptables -t nat -A POSTROUTING -j MASQUERADE -o "$networkInterfaceName"
    echo "tunnel is done Wait for other steps to take"
    apt install iptables-persistent -y
    sudo netfilter-persistent save
    iptables-save > /etc/iptables/rules.v4
    ip6tables-save > /etc/iptables/rules.v6
    echo "Your tunnel finished"
    ;;
2)
sudo iptables -t nat -F
    echo "Your forward port was removed"
  ;;
  3)
iptables -t nat -L --line-numbers
  ;;
  4)
    apt install curl socat -y
    curl https://get.acme.sh | sh
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    echo "Enter email (original or random):"
    read -r email
    ~/.acme.sh/acme.sh --register-account -m "$email"
    echo "Enter your domain:"
    read -r domain
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone
    ~/.acme.sh/acme.sh --installcert -d "$domain" --key-file /root/private.key --fullchain-file /root/cert.crt
    echo "Your SSL Cert finished"
    echo""
    echo"/root/cert.crt"
    echo"/root/private.key"
      ;;
    5)
    exit
      ;;
esac
done
