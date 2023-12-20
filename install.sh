#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color
 Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" # User must run the script as root
   sleep .5 
   sudo "$0" "$@"
   exit 1
fi
#apt --fix-broken install -y
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

while true; do
    clear
    echo -e "${BLUE}+--------------------------------------------------+${NC}"
    echo -e "${BLUE}|${NC}                         B Y                       ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}                  D E V S P A C E X                ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}            ---------------------------           |${NC}"
    echo -e "${BLUE}|${NC}                      ${GREEN}Main Menu${BLUE}                   |${NC}"
    echo -e "${YELLOW}+--------------------------------------------------+${NC}"
    echo -e "${NC} Select one of the following options${NC}"
    echo -e " ${YELLOW} 1.${NC} ${GREEN} Server tunnel${NC}"
    echo -e " ${YELLOW} 2.${NC} ${GREEN} Remove the tunnel${NC}"
    echo -e " ${YELLOW} 3.${NC} ${GREEN} View the Forwarded IP${NC}"
    echo -e " ${YELLOW} 4.${NC} ${GREEN} SSL cert${NC}"
    echo -e " ${YELLOW} 5.${NC} ${GREEN} Exit${NC}"
    echo -e "${YELLOW}+--------------------------------------------------+${NC}"
    echo -e ""
    read -p " Please select one [1-2-3-4-5]: " choice 

    case $choice in

        1)
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
        2)
            exit
            ;;
esac
