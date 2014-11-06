#!/bin/bash
#
# Simple script to switch to skydns in docker container.
# 

RESOLVCONF=/etc/resolv.conf

SKYDNS=$(ping -c 1 skydns|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
if [[ ! -z "${SKYDNS}" ]]; then
  echo "Found skydns at ${SKYDNS}"
  sed -e "s/\(nameserver\) .*/\1 ${SKYDNS}/" ${RESOLVCONF} > /tmp/resolv.conf
  cp /tmp/resolv.conf ${RESOLVCONF}
  chmod 644 ${RESOLVCONF}
  chown root:root ${RESOLVCONF}
else
  echo "Nothing changed, was unable to ping skydns!"
fi
