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
 
 #Create User
 mongo <<EOF
use admin;
db.createUser({ user: "$1" , pwd: "$2", roles: ["userAdminAnyDatabase", "dbAdminAnyDatabase", "readWriteAnyDatabase"]}) 
 EOF
