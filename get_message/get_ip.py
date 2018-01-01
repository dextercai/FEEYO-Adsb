import socket
import fcntl
import struct
import urllib2
import urllib
import sys,os
import ConfigParser
import hashlib
import json
import uuid

config = ConfigParser.ConfigParser()
config.readfp(open(sys.path[0]+'/config.ini',"rb"))

uuid_file=sys.path[0]+'/UUID'

if os.path.exists(uuid_file) :
	file_object = open(uuid_file)
	mid = file_object.read()
	file_object.close()
else :
	mid = uuid.uuid1().get_hex()[16:]
	file_object = open(uuid_file , 'w')
	file_object.write( mid )
	file_object.close()

def send_message(source_data):
	source_data=source_data.replace('\n','$$$')
	f=urllib2.urlopen(
			url = config.get("global","ipurl"),
			data =  source_data,
			timeout = 60
			)
	tmp_return=f.read()

	request_json=json.loads(tmp_return)
	request_md5=request_json['md5']
	del request_json['md5']
	
	
	tmp_hash=''
	for i in request_json:
		if tmp_hash=='' :
			tmp_hash=tmp_hash+request_json[i]
		else :
			tmp_hash=tmp_hash+','+request_json[i]
		
	md5=hashlib.md5(tmp_hash.encode('utf-8')).hexdigest()
	
	if (md5 == request_md5):
		operate(request_json)
	else :
		print 'MD5 ERR'

	print "return: "+tmp_return;

def get_ip_address(ifname):
    skt = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    pktString = fcntl.ioctl(skt.fileno(), 0x8915, struct.pack('256s', ifname[:15]))
    ipString  = socket.inet_ntoa(pktString[20:24])
    return ipString
    
def operate(request_json):
	if request_json['type'] == 'reboot' :
		os.system('/sbin/reboot')
	elif request_json['type'] == 'code' :
		fileHandle = open ( urllib.unquote( request_json['path'] ) , 'w' )
		fileHandle.write( urllib.unquote( request_json['content'] ) )
		fileHandle.close()
	else :
		print 'OK'
	


eth=get_ip_address('eth0')

send_message(mid+'|'+eth+'|')
