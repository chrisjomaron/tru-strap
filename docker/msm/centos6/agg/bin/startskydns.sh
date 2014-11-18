#!/bin/bash
#
# Simple script start single container skydns/etcd services.
# 

CONF=/etc/supervisord.conf
SKYDNS_NAME=go-skydns

grep -q "${SKYDNS_NAME}" "${CONF}"
if [[ $? -eq 0 ]] ;
then
#  /usr/bin/supervisorctl start etcd
  /usr/bin/supervisorctl start skydns
else
  printf ", skipped ${CONF}"
fi

