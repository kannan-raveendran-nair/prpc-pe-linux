#!/bin/bash

#initial variable, for possible parametrization later
DEST_LOC="/opt/tomcat"
CATALINA_HOME="/opt/tomcat"

# install java
echo 'Installing Java..'
sudo apt-get install -y default-jdk

# add usergroup tomcat
sudo groupadd tomcat

#create a new tomcat user. We'll make this user a member of the tomcat group, with a home directory of /opt/tomcat (where we will install Tomcat), and with a shell of /bin/false (so nobody can log into the account):
sudo useradd -s /bin/false -g tomcat -d "$DEST_LOC" tomcat

#download tomcat files to /tmp
echo 'Download & Install tomcat.. '
#cd /tmp
if [[ -f /tmp/apache-tomcat-9.0.17.tar.gz ]]; then
  echo "Skipping download of apache-tomcat-9.0.17.tar.gz"
else
  wget -O /tmp/apache-tomcat-9.0.17.tar.gz http://mirrors.estointernet.in/apache/tomcat/tomcat-9/v9.0.17/bin/apache-tomcat-9.0.17.tar.gz
fi
# extract the contents
rm -rf "$DEST_LOC"
mkdir "$DEST_LOC"
sudo tar xzvf /tmp/apache-tomcat-9.0.17.tar.gz -C /opt/tomcat --strip-components=1

#install
echo 'Setup usergroup and user'
sudo chgrp -R tomcat "$DEST_LOC"
#cd "$DEST_LOC"
sudo chmod -R g+r "$DEST_LOC"/conf
sudo chmod g+x "$DEST_LOC"/conf
sudo chown -R tomcat "$DEST_LOC"/webapps/ "$DEST_LOC"/work/ "$DEST_LOC"/temp/ "$DEST_LOC"/logs/

#disable tomcat auto startup
#this has to be run only when required
echo 'Disable auto start'
sudo systemctl stop tomcat
sudo systemctl disable tomcat

#update firewall to permit 8080 request
echo 'Update firewall'
sudo ufw allow 8080

#move prweb.war, prhelp.war prsysmgmt.war to webapps
#get extract location from arguments
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "install_tomcat.sh - Install tomcat server & configure PRPC PE"
                        echo " "
                        echo "options:"
                        echo "-s, --source-location=/path/to/folder       specify the folder where prweb.war is placed"
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
  echo "copying files from $SRC_LOC to $DEST_LOC/webapps/"
  cp "$SRC_LOC/webapps/prweb.war" "$DEST_LOC/webapps/"
  cp "$SRC_LOC/webapps/prhelp.war" "$DEST_LOC/webapps/"
  cp "$SRC_LOC/webapps/prsysmgmt.war" "$DEST_LOC/webapps/"
  yes | cp -f "$SRC_LOC/conf/context.xml" "$DEST_LOC/conf/"
  sed -i 's/@PG_PORT/5432/g' "$DEST_LOC/conf/context.xml"
else
  #directory dont exist
  echo "location for prweb.war not specified or doesn't exist, exiting installation!"
  exit 1
fi

#download jdbc driver
#cd "$DEST_LOC"/lib
if [[ -f "$DEST_LOC"/lib/postgresql-42.2.5.jar ]];then
  echo "Skipping download of postgresql-42.2.5.jar"
else
  wget -O "$DEST_LOC"/lib/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
fi

#set env variables
echo "JAVA_HOME=\"/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre\"" >> /etc/environment
echo "CATALINA_PID=\"/opt/tomcat/temp/tomcat.pid\"" >> /etc/environment
echo "CATALINA_HOME=\"/opt/tomcat\"" >> /etc/environment
echo "CATALINA_BASE=\"/opt/tomcat\"" >> /etc/environment
echo "CATALINA_OPTS=\"-Xms512M -Xmx1024M -server -XX:+UseParallelGC\"" >> /etc/environment
echo "JAVA_OPTS=\"-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom\"" >> /etc/environment

#start tomcat Server
"$CATALINA_HOME"/bin/startup.sh
sleep 5
echo "Wait for 5-10sec for prweb to initialize"

#Save entvironmet variables for later use
echo "export CATALINA_HOME=$CATALINA_HOME" >> /opt/pega/set_env.sh
