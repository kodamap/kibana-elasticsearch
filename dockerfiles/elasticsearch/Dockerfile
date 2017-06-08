FROM centos:centos7
MAINTAINER Hiroshi KODAMA

RUN yum -y update
RUN yum -y install java
ENV JAVE_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-2.b11.el7_3.x86_64/jre
ENV PATH $PATH:$HOME/bin:$JAVE_HOME/bin

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
COPY elasticsearch.repo /etc/yum.repos.d/
RUN yum install elasticsearch -y
RUN yum install -y initscripts

# install plugin
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-geoip --batch
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-user-agent --batch
COPY elasticsearch.yml /etc/elasticsearch/
COPY filebeat.template.json /

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]

EXPOSE 9200
