#!/usr/bin/env python
import socket, traceback ,time,urllib2,urllib,sys,ConfigParser

def send_message(source_data):
	try:
		f=urllib2.urlopen(url = config.get("global","sendurl"),data =  urllib.urlencode({'from':config.get("global","name"),'code':source_data}),timeout = 10)
		print "return: "+f.read();
		return True
	except Exception,e:
		print str(e)
		return False
		
		
host = '127.0.0.1'
port = 8888

config = ConfigParser.ConfigParser()
config.readfp(open(sys.path[0]+'/config.ini',"rb"))


s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))

while 1:
     try:
         message, address = s.recvfrom(8192)
         socket_udp_str='{0} :{1} \n\n'.format(time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())),message)
         send_message(socket_udp_str)
     except (KeyboardInterrupt, SystemExit):
         raise
     except:
         traceback.print_exc()