# kibana-elasticsearch deploy on centos

## ansible

- install ansible

http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-pip

- git clone

```
git clone https://github.com/kodamap/kibana-elasticsearch
cd kibana-elasticsearch
```

- configure ansible_host

```
[kibana-elasticsearch]
x.x.x.x

[client]
x.x.x.x
````

- install elasticsearch + kibana on the same node and beats to the clients.

```
ansible-playbook -i ansible_host kibana-elasticsearch.yml --private-key=~/private-key.pem -u centos
```

## docker

### elasticsearch + kibana

- create data directories

```
sudo mkdir -p /var/data/elasticsearch; chmod 777 /var/data/elasticsearch
sudo mkdir -p /var/data/kibana; chmod 777 /var/data/kibana
```

- build and run

```
cd dockerfiles
sudo docker build -t localhost/elasticsearch:v1 elasticsearch/
sudo docker build -t localhost/kibana:v1 kibana/
sudo docker run -v /var/data/elasticsearch:/var/lib/elasticsearch -p 9200:9200 -itd --name elasticsearch localhost/elasticsearch:v1
sudo docker run -v /var/data/kibana:/var/lib/kibana -p 5601:5601 -itd --name kibana --link elasticsearch:EL localhost/kibana:v1
```



## Reference

- elasticsearch

https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html
https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html

- plugin

https://www.elastic.co/guide/en/beats/filebeat/current/_tutorial.html

- kibana

https://www.elastic.co/guide/en/kibana/current/rpm.html

- filebeat

https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html

- packetbeat

https://www.elastic.co/guide/en/beats/packetbeat/current/packetbeat-installation.html



