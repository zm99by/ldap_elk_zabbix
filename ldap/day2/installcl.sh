#! /bin/bash
sudo yum -y install openldap-clients nss-pam-ldap
sudo authconfig --enableldap --enableldapauth --ldapserver=${Address} --ldapbasedn=dc=vladimir,dc=sakhonchik --enablemkhomedir --update
sudo systemctl restart nslcd.service
sudo sed -i 's/127.0.0.1/'${Address}'/' /etc/nslcd.conf
sudo sed -i '/base/d' /etc/nslcd.conf
sudo echo -e "dc=vladimir,dc=sakhonchik" >> /etc/nslcd.conf
sudo systemctl restart nslcd
sudo echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
sudo cat<<EOF >/opt/ssh_ldap.sh
#!/bin/bash
set -eou pipefail
IFS=$'\n\t'

result=\$(ldapsearch -x '(&(objectClass=posixAccount)(uid='"\$1"'))' 'sshPublicKey')
attrLine=\$(echo "\$result" | sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;/sshPublicKey:/p')

if [[ "\$attrLine" == sshPublicKey::* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey:: //' | base64 -d
elif [[ "\$attrLine" == sshPublicKey:* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey: //'
else
  exit 1
fi
EOF

sudo chmod +x /opt/ssh_ldap.sh

sudo cat<<EOF >>/etc/ssh/sshd_config
AuthorizedKeysCommand /opt/ssh_ldap.sh
AuthorizedKeysCommandUser nobody
EOF

sudo systemctl restart sshd