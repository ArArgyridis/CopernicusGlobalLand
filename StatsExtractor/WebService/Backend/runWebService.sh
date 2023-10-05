#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	exit 0
else
	ln -s /mnt/Data/natstats/active_config.json ../../
	nohup uwsgi statsservice.ini > statsservice_nohup.out 2>&1 &
	nohup spawn-fcgi -a 127.0.0.1 -p 1337 -F 1  /usr/bin/mapserv >/dev/null 2>&1  &
	export MAPCACHE_CONFIG_FILE=/mnt/Data/natstats/mapcache/stratifications.xml
	nohup spawn-fcgi -a 127.0.0.1 -p 1338 -F 6  /usr/bin/mapcache.fcgi >/dev/null 2>&1  &
	exit 0
fi
