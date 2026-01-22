#!/bin/bash
set -e

export PDNS_setuid=`id -u`;
  
# Create config file from template
envtpl < /pdns.conf.tpl > /etc/powerdns/pdns.conf

# Run pdns server
trap "pdns_control quit" SIGHUP SIGINT SIGTERM
pdns_server "$@" &
wait

# /usr/bin/tini -s -- /usr/local/sbin/pdns_server-startup
