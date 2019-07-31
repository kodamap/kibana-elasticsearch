# Netflow Visualization with ELK stack

## Components

components | description
----- | -----
Elasticsearch (v7.2.1) | search engine
Kibana (v7.2.1) | dashboard
Logstash (v7.2.1) | netflow collector
Nginx (optional) | reverse proxy (restricting access with HTTP Basic Authentication on kibana) * id/pass: elastic/changeme

* tested version

Kibana / Elasticsearch : 6.3.1 and 6.5.1 , Logstash : 6.3.1

## Netflow visualization 

* Use Logstash Netflow Module

https://www.elastic.co/guide/en/logstash/current/netflow-module.html

<a href="https://raw.githubusercontent.com/wiki/kodamap/kibana-elasticsearch/images/netflow_dashboard_6x.png">
<img src="https://raw.githubusercontent.com/wiki/kodamap/kibana-elasticsearch/images/netflow_dashboard_6x.png" alt="netflow_dashboard_6x" style="width:75%;height:auto;" ></a>

## Deploy elk stack on docker host

Install ansible on CentOS7 which will be docker host.

```sh
sudo yum -y install epel-release
sudo yum -y install python-devel libffi-devel openssl-devel gcc git python-pip redhat-rpm-config
sudo pip install --upgrade pip
sudo pip install paramiko
sudo pip install ansible
git clone https://github.com/kodamap/kibana-elasticsearch
```

## Install docker on CentOS7 with ansible

modify ansible_host

```sh
cd kibana-elasticsearch/playbooks/

vi ansible_host
[docker-host]
127.0.0.1
```

* install and setup docker host

```sh
ansible-playbook -i ansible_host docker.yml --key-file=~/your_private-key.pem -u centos
```

* to connect the server with password

```sh
ansible-playbook -i ansible_host docker.yml -k -u centos -c paramiko
```

## Volume setting

Each container has shared volumes whose path is "/var/data/[container name]".
see docker-compose.yml in details.

```sh
mkdir -p /var/data/elasticsearch/data
mkdir -p /var/data/elasticsearch/logs
mkdir -p /var/data/logstash
mkdir -p /var/data/kibana
mkdir -p /var/data/nginx
chmod 777 -R /var/data/elasticsearch
chmod 777 -R /var/data/logstash
chmod 777 -R /var/data/kibana
```

## Configure

* kibana (kibana-elasticsearch/dockerfiles/kibana/kibana.yml)

```sh
server.host: "0.0.0.0"
elasticsearch.url: "http://elasticsearch:9200"
```

* elasticsearch (kibana-elasticsearch/dockerfiles/elasticsearch/elasticsearch.yml)

set the container_name to `discovery.seed_hosts` and `cluster.initial_master_nodes`

https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-settings.html


```sh
network.host: 0.0.0.0
discovery.seed_hosts: elasticsearch
cluster.initial_master_nodes: elasticsearch
xpack.ml.enabled: false
``` 

* logstash (kibana-elasticsearch/dockerfiles/logstash/logstash.yml)

```sh
path.data: /var/lib/logstash
path.logs: /var/log/logstash
modules:
  - name: netflow
    var.input.udp.port: 2055
    var.elasticsearch.hosts: "elasticsearch:9200"
    var.kibana.host: "kibana:5601"
    var.elasticsearch.ssl.enabled: false
    var.kibana.ssl.enabled: false
```

* Locate the files to shared volume

```sh
cp kibana-elasticsearch/dockerfiles/kibana/kibana.yml /var/data/kibana/
cp kibana-elasticsearch/dockerfiles/elasticsearch/elasticsearch.yml /var/data/elasticsearch/
cp kibana-elasticsearch/dockerfiles/logstash/logstash.yml /var/data/logstash/
```



## build and run

* Install docker-compose

https://docs.docker.com/compose/install/#install-compose


```sh
cd ~/kibana-elasticsearch/dockerfiles/
sudo docker-compose up -d --build
```

## check deployment

```sh
sudo docker-compose ps
    Name        Command   State                Ports
------------------------------------------------------------------
elasticsearch   /run.sh   Up      0.0.0.0:9200->9200/tcp
kibana          /run.sh   Up      0.0.0.0:5601->5601/tcp
logstash        /run.sh   Up      2055/tcp, 0.0.0.0:2055->2055/udp
nginx           /run.sh   Up      0.0.0.0:5681->5681/tcp
```

* You will see kibana dashboard  

URL: http://{your ip address}:5601/


## enable logstash netflow module

* ./dockerfiles/logstash/run.sh

```sh
#!/bin/bash

LS_LOG=/var/log/logstash/logstash-plain.log
su - logstash -s /bin/bash -c \
    "export JAVA_HOME=/etc/alternatives/jre_openjdk;export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin;/usr/share/logstash/bin/logstash --path.settings /etc/logstash" &
su - logstash -s /bin/bash -c \
    "test -e ${LS_LOG} || touch ${LS_LOG}"
tail -f ${LS_LOG}
```

* ./dockerfiles/logstash/logstash.yml

```sh
path.data: /var/lib/logstash
path.logs: /var/log/logstash
modules:
  - name: netflow
    var.input.udp.port: 2055
    var.elasticsearch.hosts: "elasticsearch:9200"
    var.kibana.host: "kibana:5601"
```

## Using nginx as a reverse proxy

You can easily deploy https reverse proxy with nginx when you acesss to kibana via internet access.
ssl certificates need to be stored in /var/data/nginx.

modify docker-compose.yml and default.conf

* docker-compose.yml

This is an example using Let's encrypt certificates.
If you do not have authorized certificates files, just comment out the rows ("fullchan.pem" and "privkey.pem").

```sh
.
.
  nginx:
    build: ./nginx
    container_name: nginx
    links:
      - kibana
    volumes:
      - "/var/data/nginx/fullchain.pem:/etc/nginx/conf.d/fullchain.pem:ro"
      - "/var/data/nginx/privkey.pem:/etc/nginx/conf.d/privkey.pem:ro"
      - "/var/data/nginx/default.conf:/etc/nginx/conf.d/default.conf"
.
.
 ```

* default.conf 

Modify "ssl_certificate" in the default.conf when you use other ssl certificates (ex. Let's Encrypt)
Comment out self-signed certificates and enable certificates you want to.
Store authorized certificate /var/data/nginx/.

```sh
server {
    listen 5681 ssl;

    ssl_certificate /etc/nginx/conf.d/fullchain.pem;
    ssl_certificate_key /etc/nginx/conf.d/privkey1.pem;
    #ssl_certificate /etc/nginx/conf.d/server.crt;
    #ssl_certificate_key /etc/nginx/conf.d/server.key;
```

change base auth password (default: elastic/changeme)

* .htpasswd

```sh
htpasswd -c nginx/.htpasswd elastic
New password:
Re-type new password:

cp -p nginx/.htpasswd /var/data/nginx/
```

## Misc

netflow sample configuration on vyos

* change [logstash ip address ]on your environment.

```sh
set system flow-accounting interface 'eth0'
set system flow-accounting interface 'eth1'
set system flow-accounting netflow engine-id '100'
set system flow-accounting netflow server [logstash ip address] port '2055'
set system flow-accounting netflow version '9'
```


## Reference

* elasticsearch

https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html

* plugin

https://www.elastic.co/guide/en/beats/filebeat/current/_tutorial.html

* kibana

https://www.elastic.co/guide/en/kibana/current/rpm.html

* beats

https://www.elastic.co/guide/en/beats/libbeat/current/installing-beats.html


* Logstash Netflow Module
https://www.elastic.co/guide/en/logstash/current/netflow-module.html

