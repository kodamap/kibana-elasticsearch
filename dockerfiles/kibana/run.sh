#!/bin/bash

su - kibana -s /bin/sh -c "/usr/share/kibana/bin/../node/bin/node --no-warnings /usr/share/kibana/bin/../src/cli -c /etc/kibana/kibana.yml"
