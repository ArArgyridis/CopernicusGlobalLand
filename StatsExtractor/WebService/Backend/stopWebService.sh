#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	uwsgi --stop /tmp/stratification_stats.pid
fi

if  ps -aux | grep -v grep |grep fcgiwrap; then
	killall fcgiwrap
fi
