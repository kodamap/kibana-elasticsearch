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

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]

EXPOSE 9200