#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	uwsgi --stop /tmp/stratification_stats.pid
	exit 0
fi

if  ps -aux | grep -v grep |grep mapcache.fcgi; then
	killall mapcache.fcgi
	exit 0
fi
