#!/bin/bash

#initial variable, for possible parametrization later
DATA_LOC="/usr/local/pgsql/data"
BIN_LOC="/usr/lib/postgresql/9.5/bin"
LOG_LOC="/var/log/postgresql"

#get extract location from arguments
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "install_postgresql.sh - Install postgresql server & configure PRPC PE"
                        echo ""
                        echo "options:"
                        echo "-s, --source-location=/path/to/folder       specify the folder where pega.dump is placed"
                        exit 0
                        ;;
                -s)
                        shift
                        if test $# -gt 0; then
                                export SRC_LOC=$1
                        else
                                echo "no location specified"
                                exit 1
                        fi
                        shift
                        ;;
                --source-location*)
                        export SRC_LOC=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

if [[ -d $SRC_LOC ]];then
  true
else
  echo "Postgresql installation media missing"
  echo "Internal error on $0"
  exit 1
fi
#install postgresql and pljava
echo "Install postgresql and pljava"
echo "Fetching installation media from $SRC_LOC"

sudo apt install -y postgresql-9.5 postgresql-9.5-pljava

#get user from script
DB_USER="$(grep -oP '.*USER \K(.*)(?= PASSWORD.*)' $SRC_LOC/scripts/SetupDBandUser.sql)"

#Check if user was fetched
#if [ -z "$DB_USER" ]; then
#  echo "Internal error: DB_USER empty"
#  exit 1
#fi

useradd "$DB_USER"

#stop & remove existing postgresql service
systemctl stop postgresql.service
systemctl disable postgresql.service

rm -rf /usr/local/pgsql
mkdir "$DATA_LOC" -p

rm -rf "$LOG_LOC"
mkdir "$LOG_LOC" -p


chown "$DB_USER" "$DATA_LOC"
chown "$DB_USER" "$LOG_LOC"

#setup directories for user pega
rm -f -r /var/run/postgresql
mkdir /var/run/postgresql -p
chown "$DB_USER" /var/run/postgresql

#initialize db
echo "Initialize DB"
su -c "$BIN_LOC/initdb -D $DATA_LOC -U $DB_USER" - "$DB_USER"
#sleep 5

#start postgresql server
echo "Start postgresql server"
su -c "$BIN_LOC/pg_ctl -D  $DATA_LOC -l $LOG_LOC/postgresql.log start" - "$DB_USER"

# make sure pg is ready to accept connections
until su -c "$BIN_LOC/pg_isready -p 5432 -U $DB_USER" - "$DB_USER"
do
  echo "Waiting for postgres to startup"
  sleep 2
done

#create DB
echo "Create $DB_USER DB"
su -c "$BIN_LOC/createdb $DB_USER -O $DB_USER -T template0 -E 'UTF8'" - "$DB_USER"
until su -c "$BIN_LOC/pg_isready -p 5432 -U $DB_USER" - "$DB_USER"
do
  echo "Waiting for postgres to be ready"
  sleep 2
done

su -c "$BIN_LOC/psql -f $SRC_LOC/scripts/SetupDBandUser.sql -L $LOG_LOC/postgresql.log" - "$DB_USER"
su -c "$BIN_LOC/psql -f $PWD/postgresql/install_pljava.sql -L $LOG_LOC/postgresql.log" - "$DB_USER"
echo "Create pega DB complete!"

#restart postgresql server after DB creation
echo "Restart postgresql server"
su -c "$BIN_LOC/pg_ctl -D  $DATA_LOC -l $LOG_LOC/postgresql.log restart" - "$DB_USER"

# make sure pg is ready to accept connections
until su -c "$BIN_LOC/pg_isready -p 5432 -U $DB_USER" - "$DB_USER"
do
  echo "Waiting for postgres to restart"
  sleep 2
done

#restore pega.dump file
if [[ -d $SRC_LOC ]];then
  echo "Database restore in progress.. This will take around 10mins!"
  su -c "$BIN_LOC/pg_restore -U $DB_USER -d $DB_USER -O $SRC_LOC/pega.dump" - "$DB_USER"
  echo "Database restore complete!"
else
  echo "location for pega.dump doesn't exist or was not provided"
fi

#modify to enable external connection
echo "host    all             all              0.0.0.0/0                       md5" >> "$DATA_LOC"/pg_hba.conf
echo "host    all             all              ::/0                            md5" >> "$DATA_LOC"/pg_hba.conf
echo "listen_addresses = '*'" >> "$DATA_LOC"/postgresql.conf

#restart postgresql server after DB restoration
echo "restarting postgresql server"
su -c "$BIN_LOC/pg_ctl -D  $DATA_LOC -l $LOG_LOC/postgresql.log restart" - "$DB_USER"

# make sure pg is ready to accept connections
until su -c "$BIN_LOC/pg_isready -p 5432 -U $DB_USER" - "$DB_USER"
do
  echo "Waiting for postgres to restart"
  sleep 2
done

#Save entvironmet variables for later use
echo "export DB_USER=$DB_USER" >> /opt/pega/set_env.sh
echo "export BIN_LOC=$BIN_LOC" >> /opt/pega/set_env.sh
echo "export DATA_LOC=$DATA_LOC" >> /opt/pega/set_env.sh
echo "export LOG_LOC=$LOG_LOC" >> /opt/pega/set_env.sh
