FROM centos:centos7
MAINTAINER Hiroshi KODAMA

RUN yum -y update
RUN yum -y install java
ENV JAVA_HOME /etc/alternatives/jre_openjdk
ENV PATH $PATH:$HOME/bin:$JAVA_HOME/bin

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
COPY logstash.repo /etc/yum.repos.d/
RUN yum install logstash -y

COPY netflow.conf /etc/logstash/conf.d/

RUN curl -O http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
RUN tar zxf GeoLite2-City.tar.gz
RUN cp -p GeoLite2-City_*/GeoLite2-City.mmdb /etc/logstash/

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]

EXPOSE 2055
