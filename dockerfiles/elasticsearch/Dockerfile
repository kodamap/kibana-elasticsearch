FROM centos:centos7
MAINTAINER Hiroshi KODAMA

RUN yum -y update
RUN yum -y install java
ENV JAVA_HOME /etc/alternatives/jre_openjdk
ENV PATH $PATH:$HOME/bin:$JAVE_HOME/bin

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
COPY elasticsearch.repo /etc/yum.repos.d/
RUN yum install elasticsearch -y
RUN yum install -y initscripts

# install plugin
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip --batch
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-user-agent --batch
## RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack --batch
## COPY elasticsearch.yml /etc/elasticsearch/
COPY filebeat.template.json /

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]

EXPOSE 9200