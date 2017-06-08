#!/bin/bash

sed -i "s/^#elasticsearch.url: .*/elasticsearch.url: http:\/\/${EL_PORT_9200_TCP_ADDR}:9200/" /etc/kibana/kibana.yml
su - kibana -s /bin/sh -c "/usr/share/kibana/bin/../node/bin/node --no-warnings /usr/share/kibana/bin/../src/cli -c /etc/kibana/kibana.yml"
