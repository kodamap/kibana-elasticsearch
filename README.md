# kibana-elasticsearch deploy on centos7

## components

components | description
----- | -----
elasticsearch | search engine
kibana | dashboard
logstash | netflow collector
nginx (optional) | reverse proxy (restricting access with HTTP Basic Authentication on kibana) * id/pass: elastic/changeme

## install ansible

```sh
sudo yum -y install epel-release
sudo yum -y install python-devel libffi-devel openssl-devel gcc git python-pip redhat-rpm-config
sudo pip install --upgrade pip
sudo pip install paramiko
sudo pip install ansible
git clone https://github.com/kodamap/kibana-elasticsearch
```

## deploy elk

* modify ansible_host

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

* to connect to a server with password

```sh
ansible-playbook -i ansible_host docker.yml -k -u centos -c paramiko
```

* build and run

```sh
mkdir -p /var/data/elasticsearch/data
mkdir -p /var/data/elasticsearch/logs
mkdir -p /var/data/logstash
mkdir -p /var/data/kibana
chmod 777 -R /var/data/elasticsearch
chmod 777 -R /var/data/logstash
chmod 777 -R /var/data/kibana

cd ~/kibana-elasticsearch/dockerfiles/
sudo docker-compose up -d
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

URL : http://{your ip address}:5601/


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




