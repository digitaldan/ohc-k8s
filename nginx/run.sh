#!/bin/bash

# This custom run script allows is to grab the network resolver and inject it into 
# our nginx config so we can adjust the TTL of upstream requests to a custom level

export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr -d '\n'`
envsubst '$NAMESERVER' < /etc/nginx/nginx-ohc-nameserver.template > /etc/nginx/nginx-ohc-nameserver.include
echo "Starting nginx with nameserver $NAMESERVER"
nginx -g "daemon off;"