#! /bin/sh

nohup uwsgi statsservice.ini > statsservice_nohup.out 2>&1 &
nohup spawn-fcgi -a 127.0.0.1 -p 1337 -F 12 -u $USER -U $USER /usr/bin/mapserv >/dev/null 2>&1  &
export MAPCACHE_CONFIG_FILE=$HOME/Projects/JRCStatsExtractor/ExperimentalData/Vector/stratifications.xml
nohup spawn-fcgi -a 127.0.0.1 -p 1338 -F 12 -u $USER -U $USER /usr/bin/mapcache.fcgi >/dev/null 2>&1  &
