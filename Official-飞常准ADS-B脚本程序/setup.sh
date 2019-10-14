#!/bin/bash
clear
echo " "
echo "Setup VariFlight ADS-B Client..."
echo "You will first need a working version of any feeder before proceeding."
echo "Example FlightAware or any pre-build ADS-B image already installed."
echo "Else setup for VariFlight feeder will fail!"
echo "This setup script just borrow the existing feeder Dump1090 decoder to function."
echo " "

apt-get update -y
apt-get upgrade -y
apt-get install dos2unix -y
apt autoremove -y

cd /root/get_message/
python get_ip.py
ps aux | grep py

update-alternatives --config editor
crontab -l > mycron
#echo new cron into cron file
echo "* * * * * /root/task.sh >/dev/null 2>&1" >> mycron
echo "* * * * * /root/synctime.sh >/dev/null 2>&1" >> mycron
#install new cron file
crontab mycron
rm mycron
crontab -e

cd ~
chmod +x *.sh
chmod +x *.py
dos2unix *.*
cd get_message
chmod +x *.sh
chmod +x *.py
dos2unix *.*
cd ~

bash /root/get_message/init.sh
bash /root/task.sh
clear

echo " "
echo " "
echo "UUID : "
cat /root/get_message/UUID
echo " "
echo " "
echo "Standy by 1 minute to reboot and activation..."
echo "Please copy down the UUID code together with your"
echo "nearest airport Name / ICAO code to mailto:adsb@variflight.com"
echo "And please register online at http://flightadsb.variflight.com"
echo "for new account membership creation."
echo " "
echo "If you are using WiFi please modify {nano /root/get_message/get_ip.py}"
echo "Change the value to "eth0" to "wlan0" at the end of the script"
echo "E.g. {eth=get_ip_address('eth0')}"
echo " "
echo " "
echo "Thank you."
echo "VariFlight Team "
echo " "
echo " "
echo " "
echo " "
echo "Engineered by Rodney Yeo @ http://rodyeo@dyndns.org/"
sleep 60
reboot
