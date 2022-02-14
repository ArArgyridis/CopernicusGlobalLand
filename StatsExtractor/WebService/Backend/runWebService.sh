#! /bin/sh

nohup uwsgi statsservice.ini > statsservice_nohup.out 2>&1 &
