#!/bin/bash
ps -eaf | grep acarsdec | grep -v grep
if [ $? -eq 1 ]
then
/root/acarsdec-3.0/acarsdec -n 127.0.0.1:8888 -o 0 -p -8 -r 0 127.272 126.475 &
echo `date "+%G-%m-%d %H:%M:%S"`" acarsdec            restart"
echo "------------------------------------------------------------------------"
else
echo `date "+%G-%m-%d %H:%M:%S"`" acarsdec            running"
echo "------------------------------------------------------------------------"
fi


ps -eaf | grep get_ip.py | grep -v grep
# if not found - equals to 1, start it
if [ $? -eq 1 ]
then
python /root/get_message/get_ip.py
echo `date "+%G-%m-%d %H:%M:%S"`" get_ip            restart"
echo "------------------------------------------------------------------------"
else
echo `date "+%G-%m-%d %H:%M:%S"`" get_ip            running"
echo "------------------------------------------------------------------------"
fi

ps -eaf | grep acars.py | grep -v grep
# if not found - equals to 1, start it
if [ $? -eq 1 ]
then
python /root/get_message/acars.py
echo `date "+%G-%m-%d %H:%M:%S"`" acars            restart"
echo "------------------------------------------------------------------------"
else
echo `date "+%G-%m-%d %H:%M:%S"`" acars            running"
echo "------------------------------------------------------------------------"
fi

/usr/sbin/ntpdate pool.ntp.org > /dev/null