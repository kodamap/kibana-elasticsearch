#!/bin/bash

sed -i "s/^#elasticsearch.url: .*/elasticsearch.url: http:\/\/elasticsearch:9200/" /etc/kibana/kibana.yml
su - kibana -s /bin/sh -c "/usr/share/kibana/bin/../node/bin/node --no-warnings /usr/share/kibana/bin/../src/cli -c /etc/kibana/kibana.yml"
