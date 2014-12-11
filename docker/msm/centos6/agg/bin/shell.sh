#!/bin/bash
#
# supporting provsioning shell script.
# 
# shell.sh      Provision MSM/TSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Provision  MSM/TSM Vagrant Docker container networks
#               including go-skydns configuations.
#
#               This has beed designed to be re-entrant, i.e. it can be re-run.    
# 
# Original:     https://github.com/MSMFG/tru-strap
# Git version:  https://github.com/pauldavidgilligan-msm/tru-strap
# Git branch:   handsome-vagrant-docker


NOW=$(date "+%Y_%m_%d_%H")
VERSION=0.2.0
SCRIPTNAME=`basename $0`

JBOSS_CLI="/opt/jboss-as-7.1.1.Final/bin/jboss-cli.sh --connect --user=admin --password=password01"

# -------------------------------------------
# Functions
# -------------------------------------------

function usage {
cat <<EOF

    Usage: $0 [options]
    -h| --help             this usage text.
    -v| --version          the version.
    -n| --name             the skydns name.
    -m| --mode             the processing mode (hosts, resolv, start, config, ejbca).
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

function update_config {
  RESULT=`pgrep etcd`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring skydns service at /v2/keys/skydns/config"
    /usr/bin/curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/config \
      -d value="{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"domain\": \"${DOMAIN_NAME}\", \"nameservers\": [\"8.8.8.8:53\",\"8.8.4.4:53\"]}"
  fi
}

function update_ejbca_mysql {
  RESULT=`pgrep mysqld`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring ejbca mysql user data"
    sleep 10 # TODO: Jboss wait loop
    runuser -l jboss -c '/usr/bin/mysql -u root < /tmp/mysql-user'
    echo "Registering mysql driver with JBoss"
    runuser -l jboss -c "${JBOSS_CLI} --command=\"/subsystem=datasources/jdbc-driver=com.mysql.jdbc.Driver:add(driver-name=com.mysql.jdbc.Driver,driver-class-name=com.mysql.jdbc.Driver,driver-module-name=com.mysql,driver-xa-datasource-class-name=com.mysql.jdbc.jdbc.jdbc2.optional.MysqlXADataSource)\""
    sleep 2
  fi
}

function update_ejbca_deploy {
  RESULT=`pgrep java`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring ejbca mysql service from ant deploy"
    echo "Running in background (approx 1 min), check /tmp/ant-deploy.log ..."
    runuser -l jboss -c 'cd /opt/ejbca_ce_6_2_0 && /opt/apache-ant-1.9.4/bin/ant deploy >> /tmp/ant-deploy.log  2>&1 & '
  fi
}

function update_ejbca_install {
  RESULT=`pgrep java`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring ejbca mysql service from ant install"
    echo "Running in background (approx 2 mins), check /tmp/ant-install.log ..."
    runuser -l jboss -c 'cd /opt/ejbca_ce_6_2_0 && /opt/apache-ant-1.9.4/bin/ant install >> /tmp/ant-install.log  2>&1 & '
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

MODES="hosts resolv start config ejbca"
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
  config)
    update_config
    ;;
  ejbca)
     update_ejbca_mysql
     update_ejbca_deploy
     regex_on='BUILD SUCCESSFUL'
     regex_off='BUILD FAILED'
     tail /tmp/ant-deploy.log -n0 -F | while read line; do
       if [[ $line =~ $regex_on ]]; then
         pkill -9 -P $$ tail
         update_ejbca_install
       elif [[ $line =~ $regex_off ]]; then
         pkill -9 -P $$ tail
         echo "Failed aborting, ${regex_off}"
       fi
     done
    ;;
esac


