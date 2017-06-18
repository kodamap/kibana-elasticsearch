FROM centos:centos7
MAINTAINER Hiroshi KODAMA

RUN yum -y update
RUN yum -y install java
ENV JAVE_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-2.b11.el7_3.x86_64/jre
ENV PATH $PATH:$HOME/bin:$JAVE_HOME/bin

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
COPY kibana.repo /etc/yum.repos.d/
RUN yum install kibana -y
RUN yum install -y initscripts

# install plugin
## RUN /usr/share/kibana/bin/kibana-plugin install x-pack

COPY kibana.yml /etc/kibana/

COPY run.sh /
RUN chmod 755 /run.sh
CMD ["/run.sh"]
