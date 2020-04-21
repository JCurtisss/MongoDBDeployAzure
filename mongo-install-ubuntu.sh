# Disable THP
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo never > /sys/kernel/mm/transparent_hugepage/defrag
sudo grep -q -F 'transparent_hugepage=never' /etc/default/grub || echo 'transparent_hugepage=never' >> /etc/default/grub

# Modified tcp keepalive according to https://docs.mongodb.org/ecosystem/platforms/windows-azure/
sudo bash -c "sudo echo net.ipv4.tcp_keepalive_time = 120 >> /etc/sysctl.conf"

#Install Mongo DB
  wget -qO- https://www.mongodb.org/static/pgp/server-4.0.asc | sudo bash -c "apt-key add"
  
  sudo bash -c "echo deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse > /etc/apt/sources.list.d/mongodb-org.list"
  sudo bash -c "apt update && apt upgrade -y"
  sudo bash -c "apt install mongodb-org -y"

  sudo bash -c "apt update && apt upgrade -y"
  sudo bash -c "apt autoremove && apt clean"
  
  #Make data location
  sudo bash -c " mkdir /data /data/db"
  
  #allow root user to access mongo location
  sudo sudo bash -c "chown -R $USER /data/db"
  sudo sudo bash -c "chown -R $USER /tmp/"
    
  #sudo bash -c "ufw allow proto tcp from any to any port 27017" #recommend 'from any' to local network range
  #sudo bash -c "ufw enable"  
  
  #Remove old sock
  sudo rm -rf /tmp/mongodb-27017.sock
  
  #Config
  sudo bash -c "systemctl enable mongod"  #enables Mongo on system startup
  sudo bash -c "service mongod start"
  
  #Add Authorization
  sudo bash -c "echo ' ' >> /etc/mongod.conf"
  sudo bash -c "echo 'security:' >> /etc/mongod.conf"
  sudo bash -c "echo '  authorization: enabled' >> /etc/mongod.conf"
    
 # Uncomment this to bind to all ip addresses
 sudo sed -i -e 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf
 sudo service mongod restart
 
 #!/bin/bash

# Initialize a mongo data folder and logfile
mkdir -p /data/db
touch /var/log/mongodb.log

# Start mongodb with logging
# --logpath    Without this mongod will output all log information to the standard output.
# --logappend  Ensure mongod appends new entries to the end of the logfile. We create it first so that the below tail always finds something
/usr/bin/mongod  --quiet --logpath /var/log/mongodb.log --logappend &

# Wait until mongo logs that it's ready (or timeout after 60s)
COUNTER=0
grep -q 'waiting for connections on port' /var/log/mongodb.log
while [[ $? -ne 0 && $COUNTER -lt 60 ]] ; do
    sleep 2
    let COUNTER+=2
    echo "Waiting for mongo to initialize... ($COUNTER seconds so far)"
    grep -q 'waiting for connections on port' /var/log/mongodb.log
done

# Now we know mongo is ready and can continue with other commands
 
 #Create User
 mongo <<EOF
use admin;
db.createUser({ user: "$1" , pwd: "$2", roles: ["userAdminAnyDatabase", "dbAdminAnyDatabase", "readWriteAnyDatabase"]}) 
 EOF
