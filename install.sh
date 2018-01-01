#!/bin/bash
apt-get update
apt-get install cmake libusb-1.0-0-dev build-essential vim ntpdate -y
apt-get remove ntp

cd get_message/
mv rtl-sdr-blacklist.conf /etc/modprobe.d/
mv dump.sh /etc/init.d/dump
chmod +x /etc/init.d/dump
mv task.sh ../
chmod +x ../task.sh
cd ../rtl-sdr/
mkdir rtl
cd rtl
cmake ../ -DINSTALL_UDEV_RULES=ON
make install
ldconfig
cd ../../dump1090/
make
cd /root/get_message/
python get_ip.py 
ps aux | grep py
update-alternatives --config editor
crontab -e
* * * * * /root/task.sh >/dev/null 2>&1
* * */6 * * /root/synctime.sh >/dev/null 2>&1
