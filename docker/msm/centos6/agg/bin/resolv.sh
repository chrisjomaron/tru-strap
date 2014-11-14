#!/bin/bash
#
# Simple script to switch to skydns in docker container.
# 

CONF=/etc/resolv.conf

SKYDNS=$(ping -c 1 ${NAME}|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
if [[ ! -z "${SKYDNS}" ]]; then
  echo "Found skydns at ${SKYDNS}, updating ${CONF}."
  sed -e "s/\(nameserver\) .*/\1 ${SKYDNS}/" ${CONF} > /tmp/resolv.conf
  echo "nameserver 8.8.8.8" >> /tmp/resolv.conf
  cp /tmp/resolv.conf ${CONF}
  chmod 644 ${CONF}
  chown root:root ${CONF}
else
  echo "Nothing changed, was unable to ping skydns!"
fi
