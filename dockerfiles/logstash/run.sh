#!/bin/bash

LS_LOG=/var/log/logstash/logstash-plain.log
su - logstash -s /bin/bash -c \
    "export JAVA_HOME=/etc/alternatives/jre_openjdk;export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin;/usr/share/logstash/bin/logstash --path.settings /etc/logstash" &
su - logstash -s /bin/bash -c \
    "test -e ${LS_LOG} || touch ${LS_LOG}"
tail -f ${LS_LOG}