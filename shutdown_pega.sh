#!/bin/bash

#script to start pega Server

#initial variable, for possible parametrization later
source /opt/pega/set_env.sh
#DATA_LOC="/usr/local/pgsql/data"
#BIN_LOC="/usr/lib/postgresql/9.5/bin"
#CATALINA_HOME="/opt/tomcat"
#LOG_LOC="/var/log/postgresql/postgresql.log"

#Shutdown tomcat Server
echo "Shutdown tomcat server"
"$CATALINA_HOME"/bin/shutdown.sh
sudo ps aux | grep tomcat | awk '{print $2}' | xargs kill -9

#Shutdown Postgresql Server
echo "Shutdown postgresql server"
su -c "$BIN_LOC/pg_ctl -D  $DATA_LOC -l $LOG_LOC/postgresql.log -m smart stop" - "$DB_USER"
sudo ps aux | grep postgres | awk '{print $2}' | xargs kill -9
echo "Postgresql server shutdown complete!"

echo "Pega Server shutdown complete"
