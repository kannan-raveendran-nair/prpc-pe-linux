#!/bin/bash

#script to start pega Server

#Start Postgresql Server
echo "Start postgresql server"

#get env variable, for possible parametrization later
source /opt/pega/set_env.sh
#DATA_LOC="/usr/local/pgsql/data"
#BIN_LOC="/usr/lib/postgresql/9.5/bin"
#CATALINA_HOME="/opt/tomcat"
#LOG_LOC="/var/log/postgresql/postgresql.log"

#su -c "$BIN_LOC/pg_ctl -D  $DATA_LOC -l $LOG_LOC stop" - pega
su -c "$BIN_LOC/pg_ctl -D  $DATA_LOC -l $LOG_LOC/postgresql.log start" - "$DB_USER"

until su -c "$BIN_LOC/pg_isready -p 5432 -U $DB_USER" - "$DB_USER"
do
  echo "Waiting for postgres to startup"
  sleep 2
done
echo "Postgresql server startup complete!"


#Start tomcat Server
"$CATALINA_HOME"/bin/startup.sh
sleep 5
echo "Wait for 5-10sec for prweb to initialize"
