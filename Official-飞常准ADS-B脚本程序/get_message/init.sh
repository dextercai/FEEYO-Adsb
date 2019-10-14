#!/bin/bash

path='/root/get_message/'
DATE=`date -d "today" +"%Y-%m-%d_%H:%M:%S"`
result=""
UUID=""
execom=""
FromServer=""
SourceMD5=""
device=""

if ps -ef |grep dump1090 |grep -v grep >/dev/null
then
        device="adsb"
elif ps -ef |grep acarsdec |grep -v grep >/dev/null
then
        device="acars"
else
        device="unknow"
fi

IpAddr=`/sbin/ifconfig |grep "addr:" |grep -v 127.0.0.1 |cut -d ':' -f2 |cut -d ' ' -f1`

if [ -f "/root/get_message/UUID" ]
then
        UUID=`cat /root/get_message/UUID`
fi

execut(){
        while read command
        do
                eval $command
                if [  $? -ne 0 ]
                then
                        execom=$command
                        result=0
                        break
                fi
                result=1
        done <$path/package/exe.txt
}

removefile(){
        rm -rf $path/package
        rm -f $path/*tar.gz*
}

main(){
	ps -eaf | grep "pic.veryzhun.com/ADSB/update/newpackage.tar.gz" | grep -v grep
	if [ $? -eq 1 ]
	then
		/usr/bin/wget -P $path -c -t 1 -T 2 pic.veryzhun.com/ADSB/update/newpackage.tar.gz
        	if [ -f "$path/newpackage.tar.gz" ]
        	then
                	dmd5=`md5sum $path/newpackage.tar.gz|cut -d ' ' -f1`
                	if [ "$SourceMD5" = "$dmd5" ]
                	then
                        	/bin/tar -xzf $path/newpackage.tar.gz -C $path
                        	echo $SourceMD5 > $path/md5.txt
                        	/bin/touch /usr/src/start.pid
                        	echo $DATE > /usr/src/start.pid
                        	execut
                        	if [ $result -eq 1 ]
                        	then
                                	curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom=$execom -d message="success" http://receive.cdn35.com/ADSB/result.php
                        	else
                                	curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom=$execom -d message="fail" http://receive.cdn35.com/ADSB/result.php
                        	fi
                        	removefile
                	else
                        	curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom="------" -d message="post file has been changed" http://receive.cdn35.com/ADSB/result.php
                        	removefile
                	fi
        	else
                	curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom="------" -d message="download failed" http://receive.cdn35.com/ADSB/result.php
                	removefile
        	fi
	fi
}

if curl -m 2 -s pic.veryzhun.com/ADSB/update.php >/dev/null;then
	removefile
        FromServer=`curl -m 2 -s -d UUID="$UUID" -d IpAddr="$IpAddr" -d Device="$device" pic.veryzhun.com/ADSB/update.php`
        SourceMD5=`echo $FromServer|cut -d ' ' -f1`
	length=`echo $SourceMD5 |wc -L`
        if [ $length -ne 32 ]
        then
                curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom="------" -d message="md5 style error" http://receive.cdn35.com/ADSB/result.php
		exit
        fi
else
        curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom="------" -d message="curl failed" http://receive.cdn35.com/ADSB/result.php
        exit
fi

DesMD5=`cat $path/md5.txt`
if [ "$SourceMD5" = "$DesMD5" ]
then
        curl -m 2 -s -d UUID=$UUID -d date=$DATE -d execom="------" -d message="no update,md5 without change " http://receive.cdn35.com/ADSB/result.php
        exit
else
        main
fi
