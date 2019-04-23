#!/bin/bash

#Install/Start Pega Personal Edition
#extract arguments
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "prpc_pe.sh - Install/run PRPC PE"
                        echo " "
                        echo "options:"
                        echo "-i, --install-pega [Install Pega Personal Edition. Specify -m]"
                        echo "-m, --installation-media=/path/to/115148_PE_721.zip [Path of the zip file]"
                        echo "-o, --start-server [Start Pega Server]"
                        echo "-x, --stop-server [Shutdown Pega Server]"
                        exit 0
                        ;;
                -i|--install-pega)
                        export OPER="INSTALL"
                        shift
                        ;;
                -o|--start-server)
                        export OPER="RUN"
                        shift
                        ;;
                -x|--stop-server)
                        export OPER="STOP"
                        shift
                        ;;
                -m)
                        shift
                        if test $# -gt 0; then
                                export ZIP_LOC=$1
                        else
                                echo "zip fie location not specified"
                                exit 1
                        fi
                        shift
                        ;;
                --installation-media*)
                        export ZIP_LOC=`echo $1 | sed -e 's/^[^=]*=//g'`
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

case "$OPER" in
  INSTALL)
    #Option to install PEGA
    echo "Starting Installation"
    if [[ -f "$ZIP_LOC" ]]; then
      #If installation media specified correctly, proceed with installation
      bash "$PWD"/install_pega.sh "$ZIP_LOC" | tee /var/log/pega_install.log
    else
      #Installation media not specified/doesn't exist
      echo "Installation media not specified, or file don't exist! $ZIP_LOC"
      echo "Run prpc_pe.sh -h for more info"
      exit 1
    fi
    ;;
  RUN)
    #Option to run the already installed server
    echo "Starting PEGA Server"
    bash "$PWD"/start_pega.sh
    ;;
  STOP)
    #Option to run the already installed server
    echo "Shutting down PEGA Server"
    bash "$PWD"/shutdown_pega.sh
    ;;
  *)
    echo "No flags sepcified. Please run with appropriate flags."
    echo "Run prpc_pe.sh -h for more info"
    exit 1
    ;;
esac
