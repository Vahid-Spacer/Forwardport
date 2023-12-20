#!/bin/bash



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
    echo -e "+--------------------------------------------------+"
    echo -e "|                         B Y                       |"
    echo -e "|                  D E V S P A C E X                |"
    echo -e "|            ---------------------------           |"
    echo -e "|                      Main Menu                   |"
    echo -e "+--------------------------------------------------+"
    echo -e " Select one of the following options"
    echo -e " 1. Server tunnel"
    echo -e " 2.  Remove the tunnel"
    echo -e " 3.  View the Forwarded IP"
    echo -e " 4.  SSL cert"
    echo -e " 5.  Exit"
    echo -e "+--------------------------------------------------+"
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
