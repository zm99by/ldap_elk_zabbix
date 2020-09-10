#! /bin/bash
# $pass_user
sudo yum install -y openldap openldap-servers openldap-clients
sudo firewall-cmd --add-service=ldap
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG
sudo systemctl start slapd
sudo systemctl enable slapd
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
pass_user=12345678
pass_admin=12345678
pass_ssha=$(slappasswd -h {SSHA} -s $pass_admin)

sudo ldapadd -Y EXTERNAL -H ldapi:/// << EOF

dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $pass_ssha
EOF

cat <<SCRIPT >openssh-lpk.ldif
dn: cn=openssh-lpk,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: openssh-lpk
olcAttributeTypes: ( 1.3.6.1.4.1.24552.500.1.1.1.13 NAME 'sshPublicKey'
    DESC 'MANDATORY: OpenSSH Public key'
    EQUALITY octetStringMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )
olcObjectClasses: ( 1.3.6.1.4.1.24552.500.1.1.2.0 NAME 'ldapPublicKey' SUP top AUXILIARY
    DESC 'MANDATORY: OpenSSH LPK objectclass'
    MAY ( sshPublicKey $ uid )
    )
SCRIPT

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f openssh-lpk.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// << EOF
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=vladimir,dc=sakhonchik" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=vladimir,dc=sakhonchik

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=vladimir,dc=sakhonchik

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $pass_ssha

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by dn="cn=Manager,dc=vladimir,dc=sakhonchik" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=vladimir,dc=sakhonchik" write by * read
EOF

sudo ldapadd -x -D cn=Manager,dc=vladimir,dc=sakhonchik -w "$pass_admin" << EOF
dn: dc=vladimir,dc=sakhonchik
objectClass: top
objectClass: dcObject
objectclass: organization
o: vladimir sakhonchik
dc: vladimir

dn: cn=Manager,dc=vladimir,dc=sakhonchik
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=vladimir,dc=sakhonchik
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=vladimir,dc=sakhonchik
objectClass: organizationalUnit

ou: Group
EOF

sudo ldapadd -x -D "cn=Manager,dc=vladimir,dc=sakhonchik" -w "$pass_admin" << EOF
dn: cn=Manager,ou=Group,dc=vladimir,dc=sakhonchik
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF

ldapadd -x -D cn=Manager,dc=vladimir,dc=sakhonchik -w "$pass_admin"<< EOF
dn: uid=dsakhonchik,ou=People,dc=vladimir,dc=sakhonchik
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
objectClass: ldapPublicKey 
cn: dsakhonchik
uid: dsakhonchik
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/dsakhonchik
userPassword:  $pass_ssha
loginShell: /bin/bash
gecos: dsakhonchik
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
sshPublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsRXoZTAp5k8D+svJzfvfByZ3g3a6rqaJRCFjn/Hpk5rLeTL+73Olye03kWsevPonfjKF4W70ooQuceawOJS3lVpNt9jZChOudHh2b//p1d9CijxO+734D8VF15WCo5GBgscL/9plDnV2ApKW360MM5SynioD9RFZyL7RljadtxsZ1TEOC5Dxe2g+mq2C3j0qqzQoWnQMcFV2mAtskld1tRpAFXWBaJgxwtZABMq9dYiLW3g21gpJHaZx0EIrRtD6ra7VsEmOJZa7aItVrsKbPTTqi3tzoKbLKLjvgQerxeAxd6ujz2JCqUgdU8dKzwJHdFhY0WxDbf3C6F8rEEwo1 vs@vs
EOF

sudo yum --enablerepo=epel install -y phpldapadmin
sudo sed -i '397s|// ||' /etc/phpldapadmin/config.php
sudo sed -i '398s|^|// |' /etc/phpldapadmin/config.php
sudo cat > /etc/httpd/conf.d/phpldapadmin.conf << EOF
Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs
<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    Require all granted
  </IfModule>
  <IfModule !mod_authz_core.c>
    Order Deny,Allow
    Deny from all
    Allow from all
    Allow from ::1
  </IfModule>
</Directory>
EOF
sudo systemctl restart httpd
sudo rm -f *ldif  