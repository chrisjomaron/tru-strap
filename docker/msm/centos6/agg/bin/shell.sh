#!/bin/bash
#
# supporting provsioning shell script.
# 

NOW=$(date "+%Y_%m_%d_%H")
VERSION=0.1.0
SCRIPTNAME=`basename $0`

# -------------------------------------------
# Functions
# -------------------------------------------

function usage {
cat <<EOF

    Usage: $0 [options]
    -h| --help             this usage text.
    -v| --version          the version.
    -n| --name             the skydns name.
    -m| --mode             the processing mode (hosts, resolv, start).
    -d| --domain           the dns domain name (msm.internal, tsm.internal).
    
EOF
}

function update_hosts {
  CONF=/etc/hosts
  ETCD="etcd.${DOMAIN_NAME}"
  echo "Processing ${CONF}"
  SKYDNS=$(ping -c 1 ${SKYDNS_NAME}|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
  if [[ ! -z "${SKYDNS}" ]]; then
    printf "Found ${SKYDNS_NAME} at ${SKYDNS}"
    grep -q "${ETCD}" "${CONF}"
    if [[ $? -eq 0 ]] ;
    then
      printf ", skipped ${CONF}"
    else
      echo "${SKYDNS}    ${ETCD}" >> "${CONF}"
      printf ", updated ${CONF}"
    fi
  else
    echo "Nothing changed, was unable to ping ${SKYDNS_NAME}!"
  fi
}

function update_resolv {
  CONF=/etc/resolv.conf
  echo "Processing ${CONF}"
  SKYDNS=$(ping -c 1 ${SKYDNS_NAME}|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
  if [[ ! -z "${SKYDNS}" ]]; then
    echo "Found ${SKYDNS_NAME} at ${SKYDNS}, updating ${CONF}."
    sed -e "s/\(nameserver\) .*/\1 ${SKYDNS}/" ${CONF} > /tmp/resolv.conf
    echo "nameserver 8.8.8.8" >> /tmp/resolv.conf
    cp /tmp/resolv.conf ${CONF}
    chmod 644 ${CONF}
    chown root:root ${CONF}
  else
    echo "Nothing changed, was unable to ping ${SKYDNS_NAME}!"
  fi
}

function update_start {
  CONF=/etc/supervisord.conf
  echo "Processing ${CONF}"
  grep -q "${SKYDNS_NAME}" "${CONF}"
  if [[ $? -eq 0 ]] ;
  then
    #/usr/bin/supervisorctl start etcd
    /usr/bin/supervisorctl start skydns
  else
    printf ", skipped ${CONF}"
  fi
}


# -------------------------------------------
# Process Command Line Params
# -------------------------------------------
while test -n "$1"; do
  case "$1" in
  --help|-h)
    usage
    exit
    ;;
  --version|-v)
    echo $SCRIPTNAME $VERSION
    exit
    ;;
  --name|-n)
    SKYDNS_NAME=$2
    shift
    ;;
  --mode|-m)
    SHELL_MODE=$2
    shift
    ;;

  --domain|-d)
    DOMAIN_NAME=$2
    shift
    ;;

  *)
    echo ", unknown argument: $1"
    usage
    exit 1
    ;;
  esac
  shift
done

# -------------------------------------------
# Check
# -------------------------------------------
if [[ ${SKYDNS_NAME} == "" || ${SHELL_MODE} == "" || ${DOMAIN_NAME} == "" ]]; then
  echo ", missing argument(s)."
  usage
  exit 1
fi

MODES="hosts resolv start"
if echo "$MODES" | grep -q "$SHELL_MODE"; then
  echo "Mode is ${SHELL_MODE}"
else
  echo "${SHELL_MODE} mode must be one of [${MODES}]"
  exit 1
fi

DOMAINS="msm.internal tsm.internal"
if echo "$DOMAINS" | grep -q "$DOMAIN_NAME"; then
  echo "Domain is ${DOMAIN_NAME}"
else
  echo "${DOMAIN_NAME} mode must be one of [${DOMAINS}]"
  exit 1
fi

# -------------------------------------------
# Main
# -------------------------------------------
case "${SHELL_MODE}" in
  hosts) 
    update_hosts
    ;;
  resolv)  
    update_resolv
    ;;
  start) 
    update_start
    ;;
esac


