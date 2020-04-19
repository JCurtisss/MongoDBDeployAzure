#!/bin/bash

#
# MongoDB script
#

# Pre-req: Ubuntu Bionic (18.04) flavored distro
# Note:  To expose your server to the network, set bind to 0.0.0.0 in /etc/mongod.conf
#
# Recommended for first time users:  create a VM, ssh into it, 'wget' the raw version of this gist.

DBUSER=$1
DBPASS=$2
  
if [ -f /usr/bin/mongod ]; then
  echo "MongoDB is installed on your machine."
  kill -0 "$$" || exit
else
  echo "********************* MongoDB 4.0 INSTALL **************************"
  echo "MongoDB is is not installed."
  echo "You will be prompted several time for input during the install."
  echo "******************************************************************"
  
  wget -qO- https://www.mongodb.org/static/pgp/server-4.0.asc | sudo bash -c "apt-key add"
  
  sudo bash -c "echo deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse > /etc/apt/sources.list.d/mongodb-org.list"
  sudo bash -c "apt update && apt upgrade -y"
  sudo bash -c "apt install mongodb-org -y"

  sudo bash -c "apt update && apt upgrade -y"
  sudo bash -c "apt autoremove && apt clean"
  
  sudo bash -c " mkdir /data /data/db"
    
  sudo bash -c "ufw allow proto tcp from any to any port 27017" #recommend 'from any' to local network range
  sudo bash -c "ufw enable"
    
  sudo bash -c "echo ' ' >> /etc/mongod.conf"
  sudo bash -c "echo 'security:' >> /etc/mongod.conf"
  sudo bash -c "echo '  authorization: enabled' >> /etc/mongod.conf"    

  sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf #Set bindip arg
  
  sudo bash -c "systemctl enable mongod"  #enables Mongo on system startup
  sudo bash -c "service mongod start"
  
    mongo "admin" --eval "db.createUser({'user':'$DBUSER','pwd':'$DBPASS','roles': ['userAdminAnyDatabase','readWriteAnyDatabase']})"  
fi

echo "Script complete."
