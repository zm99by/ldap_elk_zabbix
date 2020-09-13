#!/bin/bash

sudo tee /etc/yum.repos.d/elasticsearch.repo  <<EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

sudo yum install -y --enablerepo=elasticsearch elasticsearch
sudo tee -a /etc/elasticsearch/elasticsearch.yml <<EOT

network.host: 0.0.0.0
discovery.type: single-node
EOT

sudo tee /etc/yum.repos.d/kibana.repo << EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sudo yum install -y kibana
sudo sed -i 's@\#server.host: "localhost"@server.host: "0.0.0.0"@g' /etc/kibana/kibana.yml
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
sudo systemctl enable kibana.service
sudo systemctl restart kibana
