#!/bin/bash

#See example
#https://support.rightscale.com/12-Guides/RightScale_101/08-Management_Tools/Monitoring_System/Writing_custom_collectd_plugins/Custom_Collectd_Plug-ins_for_Linux

if [ -z "${HOSTNAME}" ]; then
  echo "Undefined parameter: HOSTNAME, use the default one"
  export HOSTNAME="${COLLECTD_HOSTNAME:-`hostname -f`}"
fi

if [ -z "${INTERVAL}" ]; then
  echo "Undefined parameter: INTERVAL, use the default one"
  export INTERVAL="${COLLECTD_INTERVAL:-10}"
fi

if [ -z "${PLUGIN}" ]; then
  echo "Undefined parameter: PLUGIN, use the default one"
  export PLUGIN="exec"
fi

if [ -z "${PLUGIN_INSTANCE}" ]; then
  echo "Undefined parameter: PLUGIN_INSTANCE, use the default one"
  export PLUGIN_INSTANCE="lsof"
fi

if [ -z "${TYPE}" ]; then
  echo "Undefined parameter: TYPE, use the default one"
  export TYPE="gauge"
fi

if [ -z "${TCP_RANGE}" ]; then
  echo "Undefined parameter: TCP_RANGE, use the default one"
  export TCP_RANGE="1024-9999"
fi

if [ -z "${TCP_TYPE}" ]; then
  echo "Undefined parameter: TCP_TYPE, use the default one"
  export TCP_TYPE="ESTABLISHED"
fi

if [ -z "${USER_NAME}" ]; then
  echo "Undefined parameter: USER_NAME, use the default one"
  export USER_NAME="jenkins"
fi

#Equivalent to
#sudo watch -d -n0 "sudo lsof -iTCP:1024-9999 -sTCP:ESTABLISHED | grep jenkins"

while sleep "$INTERVAL"
do

  info=$(sudo lsof -iTCP:${TCP_RANGE} -sTCP:${TCP_TYPE} | grep ${USER_NAME})
  connected_ports=$(echo "$info"|awk -F ' ' '{print $9}'|awk -F '->' '{print $1}'|awk -F ':' '{print $2}')
  #sudo lsof -ujenkins | grep ESTABLISHED

  for VARIABLE in $connected_ports
  do
    echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-ESTABLISHED N:$VARIABLE"
    #echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-ESTABLISHED interval=$INTERVAL N:12345"
  done

done
