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
  export TCP_RANGE="1024-99999"
fi

if [ -z "${TCP_TYPE}" ]; then
  echo "Undefined parameter: TCP_TYPE, use the default one"
  export TCP_TYPE="ESTABLISHED"
fi

if [ -z "${USER_NAME}" ]; then
  echo "Undefined parameter: USER_NAME, use the default one"
  export USER_NAME="jenkins"
fi

#export LOG_DIR="/var/log/logstash"
export LOG_DIR="/tmp"
export FILENAME_BASE="${LOG_DIR}/collectd-custom-$$"
export FILENAME_EXT=".log"
FILENAME="${FILENAME_BASE}${FILENAME_EXT}"
echo "FILENAME: ${FILENAME}"
export FILENAME_ERROR="${FILENAME_BASE}_error${FILENAME_EXT}"
echo "FILENAME_ERROR: ${FILENAME_ERROR}"

#Equivalent to
#watch -n0 "sudo lsof -iTCP:1024-9999 -sTCP:ESTABLISHED -n -P -R -M -T | grep jenkins"
#for ssh
#watch -t -n.1 "lsof -i -n -P | grep sshd | grep -v \*"

while sleep "$INTERVAL"
do

  info=$(sudo lsof -iTCP:${TCP_RANGE} -sTCP:${TCP_TYPE} -n -P -R -M -T | grep ${USER_NAME})
  #echo "TEST info : $info"

  #Set the field separator to new line
  IFS=$'\n'

  #sudo lsof -ujenkins | grep ESTABLISHED
  for VARIABLE in $info
  do
    #echo "VARIABLE : ${VARIABLE}"

    pid=$(echo "${VARIABLE}"|awk -F ' ' '{print $2}')
    #echo "TEST pid : ${pid}"
    ppid=$(echo "${VARIABLE}"|awk -F ' ' '{print $3}')
    #echo "TEST ppid : ${ppid}"
    command=$(echo "${VARIABLE}"|awk -F ' ' '{print $1}')
    #echo "TEST command : ${command}"
    connected_ports=$(echo "${VARIABLE}"|awk -F ' ' '{print $10}')
    #echo "TEST connected_ports : ${connected_ports}"

    #source
    connected_ports_src=$(echo "${connected_ports}"|awk -F '->' '{print $1}'|awk -F ':' '{print $2}')
    #echo "TEST connected_ports_src : ${connected_ports_src}"
    connected_hosts_src=$(echo "${connected_ports}"|awk -F '->' '{print $2}'|awk -F ':' '{print $1}')
    #echo "TEST connected_hosts_src : ${connected_hosts_src}"
    #dest
    connected_ports_dst=$(echo "${connected_ports}"|awk -F '->' '{print $2}'|awk -F ':' '{print $2}')
    #echo "TEST connected_ports_dst : ${connected_ports_dst}"
    connected_hosts_dst=$(echo "${connected_ports}"|awk -F '->' '{print $2}'|awk -F ':' '{print $1}')
    #echo "TEST connected_hosts_dst : ${connected_hosts_dst}"

    if [ "${connected_hosts_dst}" = "127.0.0.1" ]; then
      #check integer
      if [[ ! ${connected_ports_src} =~ ^-?[0-9]+$ ]]; then
       #&& continue
       echo "Wrong port : ${connected_ports_src}" >> ${FILENAME_ERROR}
       continue
      fi
      if [[ ! ${connected_ports_dst} =~ ^-?[0-9]+$ ]]; then
       #&& continue
       echo "Wrong port : ${connected_ports_dst}" >> ${FILENAME_ERROR}
       continue
      fi

      time="$(date +%s)"
      #TYPE="lsof"
      #gksudo geany /opt/collectd/share/collectd/types.db
      #lsof		port:GAUGE:1024:9999, command:COUNTER:0:U, pid:COUNTER:0:U
      mutation=$(ps -f --pid ${pid} | grep -v grep | grep MutationTestSlave)
      #echo "TEST mutation : ${mutation} ${ppid}"
      selenium=$(ps -f --pid ${pid} | grep -v grep | grep 'selenium-server-standalone')
      surefire=$(ps -f --pid ${pid} | grep -v grep | grep 'surefire')
      if [ -z "${mutation}" -a -z "${selenium}" -a "${ppid}" != "1" ]; then

        echo "START ----------------" >> ${FILENAME}
        echo "PROCESS TIME:${time} PID:${pid} PORT_SRC:${connected_ports_src:-0} PORT_DST:${connected_ports_dst:-0}" >> ${FILENAME}

        if [ -n "${surefire}" ]; then
          echo "surefire" >> ${FILENAME}
          echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-${TCP_TYPE}_surefire ${time}:${connected_ports_dst:-0}"
          #echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-${TCP_TYPE}_${command} N:${connected_ports_src}"
          #echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-${TCP_TYPE}_pid N:${pid}"
          #echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-ESTABLISHED interval=${INTERVAL} ${connected_ports_src}:${command}:${pid}"
        else
          echo "PUTVAL ${HOSTNAME}/${PLUGIN}-${PLUGIN_INSTANCE}/${TYPE}-${TCP_TYPE}_${command} ${time}:${connected_ports_dst:-0}"
        fi

        echo "${VARIABLE}" >> ${FILENAME}
        pstree $pid >> ${FILENAME}
        ps -jfH --pid $pid >> ${FILENAME}
        echo "END ----------------" >> ${FILENAME}
      else
	    echo "Unrelevant data for ${pid}-${ppid}" >> ${FILENAME_ERROR}
        echo "${VARIABLE}" >> ${FILENAME_ERROR}
      fi
    else
	  echo "WRONG connected_hosts_dst" >> ${FILENAME_ERROR}
      echo "${VARIABLE}" >> ${FILENAME_ERROR}
    fi
  done

done
