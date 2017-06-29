#!/bin/bash

sed -i "s/KIBANA_PORT_5601_TCP_ADDR/kibana/" /etc/nginx/conf.d/default.conf
/usr/sbin/nginx -c /etc/nginx/nginx.conf
tail -f /var/log/nginx/access.log
