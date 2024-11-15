#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	exit 0
else
	ln -s /mnt/Data/natstats/active_config.json ../../
	export MAPCACHE_CONFIG_FILE=/mnt/Data/natstats/mapcache/stratifications.xml
	nohup uwsgi statsservice.ini > statsservice_nohup.out 2>&1 &
	nohup spawn-fcgi -a 127.0.0.1 -p 1337 -f "/usr/sbin/fcgiwrap -c 12" >/dev/null 2>&1  &
	exit 0
fi
