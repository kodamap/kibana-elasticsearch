FROM centos:centos7
MAINTAINER Hiroshi KODAMA

RUN yum -y update
RUN yum -y install java
ENV JAVA_HOME /etc/alternatives/jre_openjdk
ENV PATH $PATH:$HOME/bin:$JAVA_HOME/bin

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
COPY logstash.repo /etc/yum.repos.d/
RUN yum install logstash -y

COPY logstash.yml /etc/logstash/logstash.yml

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]

EXPOSE 2055