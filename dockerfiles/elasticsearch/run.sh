#!/bin/bash

su - elasticsearch -s /bin/bash -c "/usr/share/elasticsearch/bin/elasticsearch -Edefault.path.logs=/var/log/elasticsearch -Edefault.path.data=/var/lib/elasticsearch -Edefault.path.conf=/etc/elasticsearch"
