#!/bin/bash

sudo setenforce 0
sudo systemctl stop firewalld
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all
sudo yum install -y zabbix-agent
sudo yum install -y centos-release-scl

sudo cp -p /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.bkp
sudo tee /etc/zabbix/zabbix_agentd.conf << EOF
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=$server_ip
ServerActive=${server_ip}
Hostname=$HOSTNAME
HostMetadataItem=system.uname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
EOF

#sudo sed -i 's/Hostname=Zabbix\ server/Hostname=zabbix_client/' /etc/zabbix/zabbix_agentd.conf
#sudo sed -i 's/ServerActive=127.0.0.1/ServerActive=10.13.1.2/' /etc/zabbix/zabbix_agentd.conf
#sudo sed -i 's/Server=127.0.0.1/Server=10.13.1.2/' /etc/zabbix/zabbix_agentd.conf
#echo 'HostnameItem=system.hostname'| sudo tee -a /etc/zabbix/zabbix_agentd.conf
#echo 'HostMetadataItem=system.uname'| sudo tee -a /etc/zabbix/zabbix_agentd.conf
#*/

sudo systemctl restart zabbix-agent 
sudo systemctl enable zabbix-agent 

# install tom cat
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
sudo sed -i 's@<!-- <user name="admin" password="adminadmin" roles="admin,manager,admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status" /> -->@<user name="admin" password="admin" roles="admin,manager,admin-gui,admin-script,manager-gui,manager-script,manager-jmx,manager-status" />@g' /etc/tomcat/tomcat-users.xml

#restart service
sudo systemctl enable tomcat
sudo systemctl restart tomcat
sudo chmod -R 775 /var/log/tomcat