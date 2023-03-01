#! /bin/sh

if  ps -aux | grep -v grep |grep uwsgi; then
	exit 0
else
	nohup uwsgi statsservice.ini > statsservice_nohup.out 2>&1 &
	exit 0
fi
