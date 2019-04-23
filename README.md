# Linux Installer for PEGA Personal Edition

This project is intended to help Linux users install & use PEGA PRPC Personal Edition - specifically Ubuntu flavours.

These scripts have been tested with Pega Personal Editions 7.2.1 & 8.1 in Ubuntu 16.04 LXD. However this should work right out-of-the-box for most flavours of Ubuntu 16.04 and above.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You would need the following requisites to use this project

**Hardware Requirements**
* Memory  : 4 GB minimum
* Active internet connection with decent speed. Installation dowloads around 250-300MB of data - and will vary from machine to machine based on the packages already installed and how up-to-date the machine is.
* Atleast 5-7 GB of free disk space

**OS Requirement**
* Project is specific for Ubuntu based flavours.

**Files**
* PEGA PRPC Personal Edition zip file downloaded from PEGA website
  * Pega.com > Support > Download Pega Software > [Download Personal Edition](https://community1.pega.com/digital-delivery)
  * This file has to be supplied to the installation file while installing PEGA PRPC PE.

### Installing

PEGA PRPC Personal Edition for Linux can be installed by running the installation script provided with this project. The project has been written in a way that no confirmation is asked to user during installation, so the installation can be launched and left to run without intervention.

However since the project is still in beta, its best to check on the progress of installation from time-to-time to make sure that the installation has not crashed, or has thrown any unexpected errors.

The whole installation takes around 10-15mins. But this will vary from machine to machine based on user's internet speed and specs of PC.

**Steps**
1. Download and extract "*Linux Installer for PEGA Personal Edition*" latest from github

```bash
#Download files to /tmp so that they are auto-removed on next boot
cd /tmp

#Download project
wget https://github.com/kannan-raveendran-nair/prpc-pe-linux/archive/master.zip -O prpc-pe-linux-master.zip

#Extract zip to folder
sudo apt install -y unzip         #Install uznip utility
unzip prpc-pe-linux-master.zip    #Unzip project
```

2. Launch installation using the following command. Installation might take upto 15mins, sit back & relax.

```bash
#move to project folder
cd prpc-pe-linux-master                         

#launch Installation
#substitute /path/to/115148_PE_721.zip with full file path downloaded in Prerequisites/Files
bash prpc_pe.sh \
 --install-pega \
 --installation-media=/path/to/115148_PE_721.zip
```

At the end of installation both tomcat & postgresql servers are automatically started.
Later on these servers can be started & shutdown for use using prpc_pe.sh as mentioned below.

## Startup & Shutdown servers

After installation the servers tomcat (running prweb for PEGA PRPC) and postgresql (backend for PEGA PRPC in this installation) are automatically started. However its advised to shutdown the servers after use so that your PC memory is not consumed unnecessarily.

At the end of installation, required script to Startup & Shutdown servers are copied to `/opt/pega`.

**Server Startup**

Run the below commands to startup both postgresql & tomcat servers
```bash
#Start PEGA (startup Tomcat & Postgresql servers)
bash /opt/pega/prpc_pe.sh --start-server
```

**Server Shutdown**

Run the below commands to shutdown both postgresql & tomcat servers
```bash
#Stop PEGA (shutdown Tomcat & Postgresql servers)
bash /opt/pega/prpc_pe.sh --stop-server
```
## Accessing PEGA Developer Studio
Visit ```http://<server_ip>:8080/prweb/``` to login to PEGA Developer Studio. For most of you, this will be ```http://localhost:8080/prweb/```.

Use default credentials for the first login, and create a user for yourself.

**Default User  : administrator@pega.com**

**Password        : install**

## Additional notes on Installation
__Tomcat Installation__
* This setup don't enable host-manager/manager logins. Follow below steps to allow host-manager/manager
  * edit ```/opt/tomcat/conf/tomcat-users.xml``` to add the below line
  ```xml
  	<user username="admin" password="password" roles="manager-gui,admin-gui"/>
  ```

  * 	change  as below to enable remote login
  ```xml
	 <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
			 allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />-->
   ```
   in files
   ```bash
   /opt/tomcat/webapps/manager/META-INF/context.xml
   /opt/tomcat/webapps/manager/META-INF/context.xml
   ```

## Authors

* **Kannan Raveendran Nair** - *Initial work* - [kannan-raveendran-nair](https://github.com/kannan-raveendran-nair)

See also the list of [contributors](https://github.com/kannan-raveendran-nair/prpc-pe-linux/contributors) who participated in this project.

## License

This project is licensed under [Attribution-NonCommercial 4.0 International](https://creativecommons.org/licenses/by-nc/4.0/). You are free to copy, modify & redistribute this code for non-commercial purposes.

Use of Pega Personal Edition itself is licensed by PEGA and licensing details can be found in the zip file downloaded in Prerequisites/Files
