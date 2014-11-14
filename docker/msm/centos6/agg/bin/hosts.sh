#!/bin/bash
#
# Simple script to add alias for etcd.msm.internal in docker container.
# 

CONF=/etc/hosts
ETCD="etcd.msm.internal"

SKYDNS=$(ping -c 1 go-skydns|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
if [[ ! -z "${SKYDNS}" ]]; then
  printf "Found skydns at ${SKYDNS}"
  grep -q "${ETCD}" "${CONF}"
  if [[ $? -eq 0 ]] ;
  then
    printf ", skipped ${CONF}"
  else
    echo "${SKYDNS}    ${ETCD}" >> "${CONF}"
    printf ", updated ${CONF}"
  fi
else
  echo "Nothing changed, was unable to ping skydns!"
fi
