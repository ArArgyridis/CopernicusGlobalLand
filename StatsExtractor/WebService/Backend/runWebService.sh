#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	exit 0
else
	ln -s /Mapserver/active_config.json /usr/src/app/StatsExtractor
	nohup uwsgi statsservice.ini > statsservice_nohup.out 2>&1 &
	nohup spawn-fcgi -a 127.0.0.1 -p 1337 -F 1 -u $USER -U $USER /usr/bin/mapserv >/dev/null 2>&1  &
	export MAPCACHE_CONFIG_FILE=/Data/stratifications.xml
	nohup spawn-fcgi -a 127.0.0.1 -p 1338 -F 6 -u $USER -U $USER /usr/bin/mapcache.fcgi >/dev/null 2>&1  &
	exit 0
fi
