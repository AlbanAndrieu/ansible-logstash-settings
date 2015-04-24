#!/bin/bash

HOSTNAME="${COLLECTD_HOSTNAME:-`hostname -f`}"
INTERVAL="${COLLECTD_INTERVAL:-10}"
PLUGIN="exec"
PLUGIN_INSTANCE="lsof"
TYPE="gauge"

while sleep "$INTERVAL"
do

info=$(sudo lsof -iTCP:1024-9999 -sTCP:ESTABLISHED | grep jenkins)
connected_ports=$(echo "$info"|awk -F : '{print $2}')
#sudo lsof -ujenkins | grep ESTABLISHED

echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-ESTABLISHED N:$connected_ports"
#echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-ESTABLISHED interval=$INTERVAL N:12345"

done
