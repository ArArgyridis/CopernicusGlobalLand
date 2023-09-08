#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	uwsgi --stop /tmp/stratification_stats.pid
fi

if  ps -aux | grep -v grep |grep mapcache.fcgi; then
	killall mapcache.fcgi
fi

if  ps -aux | grep -v grep |grep mapserv; then
	killall mapserv
fi
