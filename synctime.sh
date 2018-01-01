#!/bin/bash

/usr/sbin/ntpdate time.windows.com > /dev/null 2>&1

if [ $? -ne 0 ] 
  then 
    /usr/sbin/ntpdate 1.cn.pool.ntp.org > /dev/null 2>&1
fi
