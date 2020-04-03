FROM centos:centos7
MAINTAINER Hiroshi KODAMA

RUN yum -y update
RUN yum -y install java
ENV JAVA_HOME /etc/alternatives/jre_openjdk
ENV PATH $PATH:$HOME/bin:$JAVA_HOME/bin

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
COPY logstash.repo /etc/yum.repos.d/
RUN yum install logstash-7.3.2 -y

# Add and Update Required Logstash plugins for ElastiFlow
RUN /usr/share/logstash/bin/logstash-plugin install logstash-codec-sflow
RUN /usr/share/logstash/bin/logstash-plugin update logstash-codec-netflow
RUN /usr/share/logstash/bin/logstash-plugin update logstash-input-udp
RUN /usr/share/logstash/bin/logstash-plugin update logstash-input-tcp
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-dns
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-geoip
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-translate

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]

EXPOSE 2055