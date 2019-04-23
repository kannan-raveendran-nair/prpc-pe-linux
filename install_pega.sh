#!/bin/bash

PEGA_TEMP="/tmp/pegatemp"

#Add sources to install pljava
sudo apt-get install -y curl ca-certificates
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

#update system
sudo apt update && sudo apt -y upgrade

#Script to install pega tomcat & __Postgresql
rm /opt/pega -rf
mkdir /opt/pega
echo "#!/bin/bash"> /opt/pega/set_env.sh

if [[ -f "$1" ]]; then
  echo "Unzip zip file to /tmp/pegatemp"
  echo "Install unzip utility"
  sudo apt install -y unzip

  #unzip relevant files
  rm -rf "$PEGA_TEMP"
  mkdir "$PEGA_TEMP" -p
  echo "Extracting pega database restore. This might take few minutes!"
  unzip "$1" data/pega.dump -d "$PEGA_TEMP"
  echo "Extracting pega database complete."
  echo "Extracting prweb.war prhelp.war prsysmgmt.war"
  unzip "$1" PRPC_PE.jar -d "$PEGA_TEMP"
  unzip "$PEGA_TEMP"/PRPC_PE.jar PersonalEdition.zip -d "$PEGA_TEMP"/PRPC_PE

  #Extract web application
  unzip "$PEGA_TEMP"/PRPC_PE/PersonalEdition.zip tomcat/webapps/prweb.war -d "$PEGA_TEMP"/PRPC_PE
  unzip "$PEGA_TEMP"/PRPC_PE/PersonalEdition.zip tomcat/webapps/prhelp.war -d "$PEGA_TEMP"/PRPC_PE
  unzip "$PEGA_TEMP"/PRPC_PE/PersonalEdition.zip tomcat/webapps/prsysmgmt.war -d "$PEGA_TEMP"/PRPC_PE
  unzip "$PEGA_TEMP"/PRPC_PE/PersonalEdition.zip tomcat/conf/context.xml -d "$PEGA_TEMP"/PRPC_PE

  #Extract DB Scripts
  unzip "$PEGA_TEMP"/PRPC_PE/PersonalEdition.zip scripts/SetupDBandUser.sql -d "$PEGA_TEMP"/data
  echo "Extration complete!"

  echo "Start Postgresql Installation"
  bash "$PWD"/postgresql/install_postgresql.sh -s "$PEGA_TEMP"/data/
  echo "Postgresql insallation complete!"

  echo "Start tomcat installaion"
  bash "$PWD"/tomcat/install_tomcat.sh -s "$PEGA_TEMP"/PRPC_PE/tomcat
  echo "Tomcat insallation complete!"

  #move startup & shutdown scripts for later use
  cp "$PWD"/shutdown_pega.sh /opt/pega/
  cp "$PWD"/start_pega.sh /opt/pega/

  rm -rf "$PEGA_TEMP"   #remove extracted files after use
  echo "Installation complete"

else
  echo "Installation media missing"
  echo "Internal error on $0"
  exit 1
fi
