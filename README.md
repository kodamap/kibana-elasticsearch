
# 1. Netflow monitoring using ElastiFlow on ELK stack

This is netflow visualization example on ELK Stack using Elastiflow (based on [ElastiFlow™ Installation](https://github.com/robcowart/elastiflow/blob/master/INSTALL.md))

<!-- TOC -->

- [1. Netflow monitoring using ElastiFlow on ELK stack](#1-netflow-monitoring-using-elastiflow-on-elk-stack)
- [2. Environment](#2-environment)
- [3. Netflow visualization](#3-netflow-visualization)
    - [3.1. Install docker on CentOS7 with ansible](#31-install-docker-on-centos7-with-ansible)
- [4. Setup ELK stack](#4-setup-elk-stack)
    - [4.1. Create volumes](#41-create-volumes)
    - [4.2. Elasticsearch](#42-elasticsearch)
    - [4.3. Logstash](#43-logstash)
    - [4.4. Kibana](#44-kibana)
- [5. Copy configuration files](#5-copy-configuration-files)
- [6. Build ELK stack for ElastiFlow](#6-build-elk-stack-for-elastiflow)
- [7. Kibana Dashboard](#7-kibana-dashboard)
- [8. Misc (Router configuration sample)](#8-misc-router-configuration-sample)

<!-- /TOC -->

# 2. Environment

Tested Enviroment(This example uses custom docker image (**Not official image**))

- Docker host (VM): CentOS 7.6 (2vCPU, RAM 6GB)
- [ELK Stack](https://www.elastic.co/what-is/elk-stack) (Containers)
- [ElatiFlow](https://github.com/robcowart/elastiflow)

components | description
----- | -----
Elasticsearch ( v7.3.1 ) | search engine
Kibana ( v7.3.1 ) | dashboard
Logstash ( v7.3.1 ) | netflow collector
ElastiFlow ( v3.5.1 ) | netflow plugin


# 3. Netflow visualization 

- ElastiFlow dashboard example

<a href="https://raw.githubusercontent.com/wiki/kodamap/kibana-elasticsearch/images/elastiflow_dashboard_73x.png
">
<img src="https://raw.githubusercontent.com/wiki/kodamap/kibana-elasticsearch/images/elastiflow_dashboard_73x.png
" alt="elastiflow_dashboard_73x" style="width:75%;height:auto;" ></a>

## 3.1. Install docker on CentOS7 with ansible

Install ansible on CentOS7 which will be docker host.

```sh
sudo yum -y install epel-release
sudo yum -y install python-devel libffi-devel openssl-devel gcc git python-pip redhat-rpm-config
sudo pip install --upgrade pip
sudo pip install paramiko
sudo pip install ansible
git clone https://github.com/kodamap/kibana-elasticsearch
```

Modify ansible_host

```sh
cd kibana-elasticsearch/playbooks/

vi ansible_host
[docker-host]
127.0.0.1
```

Run playbook

```sh
ansible-playbook -i ansible_host docker.yml --key-file=~/your_private-key.pem -u centos
```

If you use password to connect the server

```sh
ansible-playbook -i ansible_host docker.yml -k -u centos -c paramiko
```

# 4. Setup ELK stack

```sh
git clone https://github.com/kodamap/kibana-elasticsearch
cd kibana-elasticsearch/dockerfiles/
```

## 4.1. Create volumes

- Create volumes on docker host mounted in containers

```sh
sudo mkdir -p /var/data/elasticsearch/data
sudo mkdir -p /var/data/elasticsearch/logs
sudo mkdir -p /var/data/logstash
sudo mkdir -p /var/data/kibana
sudo chmod 777 -R /var/data/elasticsearch
sudo chmod 777 -R /var/data/logstash
sudo chmod 777 -R /var/data/kibana
```

## 4.2. Elasticsearch

- elasticsearch/elasticsearch.yml

This is single-node type example. Please set `discovery.seed_hosts` and `discovery_type`

```sh
network.host: 0.0.0.0
discovery.seed_hosts: elasticsearch
discovery.type: single-node
xpack.ml.enabled: false

# Elasticsearch 7.x, require that the following settings be made in elasticsearch.yml
indices.query.bool.max_clause_count: 8192
search.max_buckets: 100000
```

## 4.3. Logstash

- logstash/jvm.options

setup heap size

```sh
-Xms2g
-Xmx2g
```

Ref: [Elastiflow install Document](https://github.com/robcowart/elastiflow/blob/master/INSTALL.md)(1. Set JVM heap size.). 
> It is recommended that Logstash be given at least 2GB of JVM heap.

This example uses ElastiFlow. Comment out `netflow module` if you use netflow module.

* logstash/logstash.yml

```sh
path.data: /var/lib/logstash
path.logs: /var/log/logstash
#modules:
#  - name: netflow
#    var.input.udp.port: 2055
#    var.elasticsearch.hosts: "elasticsearch:9200"
#    var.kibana.host: "kibana:5601/kibana"
#    var.elasticsearch.ssl.enabled: false
#    var.kibana.ssl.enabled: false
```

**Note:** If `module` are specified, you will get following error.

```log
logstash         | [2019-08-22T22:24:30,187][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
```

- Dokerfile

Make sure to update Logstash plugin for ElastiFlow.

```sh
..
RUN /usr/share/logstash/bin/logstash-plugin install logstash-codec-sflow
RUN /usr/share/logstash/bin/logstash-plugin update logstash-codec-netflow
RUN /usr/share/logstash/bin/logstash-plugin update logstash-input-udp
RUN /usr/share/logstash/bin/logstash-plugin update logstash-input-tcp
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-dns
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-geoip
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-translate
..
```

Copy `elastiflow` floder to the Logstash volume you created earlier.

```sh
cd ~/
git clone https://github.com/robcowart/elastiflow
cp -pr elastiflow/logstash/elastiflow /var/data/logstash/.
```

Change `ELASTIFLOW_ES_HOST` to container name of EL(ex. `elasticsearch`).

- /var/data/logstash/elastiflow/conf.d/30_output_10_single.logstash.conf

```sh
output {
  elasticsearch {
    id => "output_elasticsearch_single"
    ##hosts => [ "${ELASTIFLOW_ES_HOST:127.0.0.1:9200}" ]
    hosts => [ "${ELASTIFLOW_ES_HOST:elasticsearch:9200}" ]
    ...
```

**Note:** Setting environment variable `ELASTIFLOW_ES_HOST` in `docker-compose.yml` did not work for this environment.

- logstash/pipelines.yml

```sh
cd ~/kibana-elasticsearch/dockerfiles/
```

```yml
# This file is where you define your pipelines. You can define multiple.
# For more information on multiple pipelines, see the documentation:
#   https://www.elastic.co/guide/en/logstash/current/multiple-pipelines.html

- pipeline.id: main
  path.config: "/etc/logstash/conf.d/*.conf"
- pipeline.id: elastiflow
  path.config: "/etc/logstash/elastiflow/conf.d/*.conf"
```

- docker-compose.yml example (Logstash part)

```yml
version: "3"
services:
...
  logstash:
    build: ./logstash
    container_name: logstash
    links:
      - elasticsearch
    volumes:
      - "/var/data/logstash/logstash.yml:/etc/logstash/logstash.yml:ro"
      - "/var/data/logstash:/var/lib/logstash"
      - "/var/data/logstash/jvm.options:/etc/logstash/jvm.options:ro"
      - "/var/data/logstash/elastiflow:/etc/logstash/elastiflow"
      - "/var/data/logstash/pipelines.yml:/etc/logstash/pipelines.yml:ro"
    ports:
      - "2055:2055/udp"
    logging:
      driver: "json-file"
      options:
        max-size: "10240k"
        max-file: "10"
    restart: unless-stopped
...
```

## 4.4. Kibana

- kibana/kibana.yml

This example add `server.basePath` and `server.rewriteBasePath` to be able to locate kibana behind reverse proxy.


```yml
server.host: "0.0.0.0"
elasticsearch.hosts: "http://elasticsearch:9200"
server.basePath: "/kibana"
server.rewriteBasePath: true
```


# 5. Copy configuration files

```sh
cp elasticsearch/elasticsearch.yml /var/data/elasticsearch
cp logstash/logstash.yml /var/data/logstash
cp logstash/jvm.options /var/data/logstash
cp logstash/pipelines.yml /var/data/logstash
cp kibana/kibana.yml /var/data/kibana
```

# 6. Build ELK stack for ElastiFlow

```sh
sudo docker-compose up -d --build

docker-compose ps
    Name        Command   State                Ports
------------------------------------------------------------------
elasticsearch   /run.sh   Up      0.0.0.0:9200->9200/tcp
kibana          /run.sh   Up      0.0.0.0:5601->5601/tcp
logstash        /run.sh   Up      2055/tcp, 0.0.0.0:2055->2055/udp
```

You will see Kibana dashboard

URL: http://{docker host ip address}:5601/kibana

# 7. Kibana Dashboard

Support for JSON files is going away with Kibana 7.3. You have to import `elastiflow.kibana.7.3.x.ndjson` (located at `elastiflow/kibana/`)

Ref: [Elastiflow install Document](https://github.com/robcowart/elastiflow/blob/master/INSTALL.md)(Configuring Kibana)
> Kibana 6.5.x and Later
The Index Patterns, vizualizations and dashboards can be loaded into Kibana by importing the elastiflow.kibana.<VER>.json file from within the Kibana UI. This is done from the Management -> Saved Objects page.



# 8. Misc (Router configuration sample)

- vyos

change [logstash ip address ].

```sh
set system flow-accounting interface 'eth0'
set system flow-accounting interface 'eth1'
set system flow-accounting netflow engine-id '100'
set system flow-accounting netflow server [logstash ip address] port '2055'
set system flow-accounting netflow version '9'
```

- Cisco IOS ( tested with IOS 15.5)

change [interface name] and [logstash ip address].

```sh
interface [interface name]
 ip flow ingress

ip flow-export source [interface name]
ip flow-export version 9
ip flow-export interface-names
ip flow-export destination [logstash ip address] 2055
```

https://www.cisco.com/c/ja_jp/td/docs/cian/ios/ios15-2m-t/cg/001/nf-15-2mt/cfg-nflow-data-expt.html 

- Fortigate FortiOS (version 5.2+)

change [logstash ip address], [ip address of device to send flow] and [interface name].

```sh
config system netflow
set collector-ip [logstash ip address]
set collector-port 2055
set source-ip [ip address of device to send flow]
set active-flow-timeout 1
set inactive-flow-timeout 15
end

config system interface
edit [interface name]
set netflow-sampler tx
end

diagnose test application sflowd 3
diagnose test application sflowd 4
```

https://www.manageengine.com/products/netflow/help/fortigate-fortios-netflow-configuration.html 
