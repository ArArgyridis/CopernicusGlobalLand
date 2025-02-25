#! /bin/sh

if  ps -aux | grep -v grep |grep 'uwsgi NatStats.ini'; then
	uwsgi --stop /tmp/NatStatsUWSGI.pid
fi

if  ps -aux | grep -v grep |grep fcgiwrap; then
	ps aux | grep '[f]cgiwrap' | awk '{print $2}' | xargs kill -SIGTERM
fi

if ps -aux | grep -v grep |grep mapserv; then
	killall -s SIGKILL mapserv
fi

if ps -aux | grep -v grep |grep mapcache.fcgi; then
	killall -s SIGKILL mapcache.fcgi
fi

