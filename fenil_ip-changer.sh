#!/bin/bash

[[ "$UID" -ne 0 ]] && {
    echo "Script must be run as root."
    exit 1
}

install_packages() {
    local distro
    distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    distro=${distro//\"/}
    
    case "$distro" in
        *"Ubuntu"* | *"Debian"*)
            apt-get update
            apt-get install -y curl tor
            ;;
        *"Fedora"* | *"CentOS"* | *"Red Hat"* | *"Amazon Linux"*)
            yum update
            yum install -y curl tor
            ;;
        *"Arch"*)
            pacman -S --noconfirm curl tor
            ;;
        *)
            echo "Unsupported distribution: $distro. Please install curl and tor manually."
            exit 1
            ;;
    esac
}

if ! command -v curl &> /dev/null || ! command -v tor &> /dev/null; then
    echo "Installing curl and tor"
    install_packages
fi

if ! systemctl --quiet is-active tor.service; then
    echo "Starting tor service"
    systemctl start tor.service
fi

get_ip() {
    local url get_ip ip
    url="https://checkip.amazonaws.com"
    get_ip=$(curl -s -x socks5h://127.0.0.1:9050 "$url")
    ip=$(echo "$get_ip" | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
    echo "$ip"
}

change_ip() {
    echo "Reloading tor service"
    systemctl reload tor.service
    echo -e "\033[34mNew IP address: $(get_ip)\033[0m"
}

clear
cat << "EOF"
  _____          _   _       _ _     
 |  ___|__  _ __| |_| |__   (_) |_  
 | |_ / _ \| '__| __| '_ \  | | __| 
 |  _| (_) | |  | |_| | | | | | |_  
 |_|  \___/|_|   \__|_| |_| |_|\__| 
                                                              
  ____   _  _    ___    ____     ____ _   _    _    _   _  ____ _____ ____  
 |  _ \ | || |  / _ \  | __ )   / ___| | | |  / \  | \ | |/ ___| ____|  _ \ 
 | |_)| | || |_| | | | |  _ \  | |   | |_| | / _ \ |  \| | |  _|  _| | |_) |
 |  __/ |__   _| |_| | | |_) | | |___|  _  |/ ___ \| |\  | |_| | |___|  _ < 
 |_|       |_|  \___/  |____/   \____|_| |_/_/   \_\_| \_|\____|_____|_| \_\ 
 
 ============================================================================
 Tool:- "AnonySwitch" – Emphasizing anonymity and switching IPs.
 Created By:- Fenil Galani  
 Project Name:- Forth it P40B CHANGER  | Atmiya University
 LinkedIn :- www.linkedin.com/in/galani-fenil-372b042a7
 GitHub:- https://github.com/fenilgalani07
 ============================================================================

EOF

while true; do
    read -rp $'\033[34mEnter time interval in seconds (type 0 for infinite IP changes): \033[0m' interval
    read -rp $'\033[34mEnter number of times to change IP address (type 0 for infinite IP changes): \033[0m' times

    if [ "$interval" -eq "0" ] || [ "$times" -eq "0" ]; then
        echo "Starting infinite IP changes"
        while true; do
            change_ip
            interval=$(shuf -i 10-20 -n 1)
            sleep "$interval"
        done
    else
        for ((i=0; i< times; i++)); do
            change_ip
            sleep "$interval"
        done
    fi
done
